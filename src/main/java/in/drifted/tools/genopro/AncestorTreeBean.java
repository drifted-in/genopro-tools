/* 
 * Copyright (c) 2015-present Jan Tošovský <jan.tosovsky.cz@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package in.drifted.tools.genopro;

import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.OutputStream;
import java.io.Serializable;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpSessionBindingEvent;
import javax.servlet.http.HttpSessionBindingListener;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import org.primefaces.event.FileUploadEvent;
import org.primefaces.model.file.UploadedFile;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

@ManagedBean
@SessionScoped
public final class AncestorTreeBean implements Serializable, HttpSessionBindingListener {

    private static final String SAMPLE_SOURCE_FILE_NAME = "premysl.gno";
    private static final String SAMPLE_SOURCE_FILE_PATH = Constants.RESOURCES_PATH + "samples/" + SAMPLE_SOURCE_FILE_NAME;

    private transient Path sourcePath;
    private transient Path outputFolderPath;
    private transient Path tempFolderPath;
    private transient Path ancestorTreePath;
    private transient Path finalPath;
    private transient List<SelectItem> individualList;
    private transient String currentId;
    private transient Boolean useSampleSource;
    private transient int generations;
    private transient int filesCount;
    private transient Map<String, InputStream> fileStreamMap;
    
    public AncestorTreeBean() throws IOException {
        initBean();
    }

    private void initBean() throws IOException {

        initOutputFolderPath();

        sourcePath = Files.createTempFile("merged-", ".xml");
        tempFolderPath = Files.createTempDirectory(AncestorTreeBean.class.getName()).toAbsolutePath();
        ancestorTreePath = Files.createTempFile("ancestor-tree-", ".xml");
        finalPath = Files.createTempFile(outputFolderPath, "ancestor-tree-", ".svg");
        individualList = new ArrayList<>();
        currentId = null;
        useSampleSource = true;
        generations = 8;
        filesCount = 0;
        fileStreamMap = new HashMap<>();

        resetSource();
    }

    private void initOutputFolderPath() throws IOException {

        if (outputFolderPath == null) {
            ServletContext context = (ServletContext) FacesContext.getCurrentInstance().getExternalContext().getContext();
            outputFolderPath = Paths.get(context.getRealPath("/output"));

            if (Files.notExists(outputFolderPath)) {
                Files.createDirectories(outputFolderPath);
            }
        }
    }

    private void initSampleSource() throws IOException {

        try (InputStream inputStream = AncestorTreeBean.class.getResourceAsStream(SAMPLE_SOURCE_FILE_PATH)) {
            FileUtil.storeFile(SAMPLE_SOURCE_FILE_NAME, inputStream, sourcePath);
        }
    }

    private void initIndividualList() {

        individualList.clear();

        try (InputStream inputStream = Files.newInputStream(sourcePath)) {

            DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
            Document document = builder.parse(inputStream);

            NodeList individualNodeList = document.getElementsByTagName("Individual");

            for (int i = 0; i < individualNodeList.getLength(); i++) {
                Node individualNode = individualNodeList.item(i);
                if (individualNode instanceof Element) {
                    Element individual = (Element) individualNode;
                    String id = individual.getAttribute("ID");

                    NodeList displayNodeList = individual.getElementsByTagName("Display");
                    if (displayNodeList.getLength() > 0) {
                        String name = displayNodeList.item(0).getTextContent();
                        individualList.add(new SelectItem(id, id + " [" + name + "]"));
                    }
                }
            }

        } catch (IOException | ParserConfigurationException | SAXException e) {

        }

        Collections.sort(individualList, new GenoProIdComparator());

        if (!individualList.isEmpty()) {
            currentId = individualList.get(0).getValue().toString();
        }
    }

    // restores transient properties when deserialized
    private void readObject(ObjectInputStream inputStream) throws IOException, ClassNotFoundException {
        inputStream.defaultReadObject();
        initBean();
    }

    @Override
    public void valueBound(HttpSessionBindingEvent event) {
    }

    @Override
    public void valueUnbound(HttpSessionBindingEvent event) {

        try {
            Files.deleteIfExists(sourcePath);
            Files.deleteIfExists(finalPath);
            Files.deleteIfExists(tempFolderPath);


        } catch (IOException e) {
        }
    }

    public void setFilesCount() {
        Map<String, String> params = FacesContext.getCurrentInstance().getExternalContext().getRequestParameterMap();
        filesCount = Integer.valueOf(params.get("filesCount"));
        fileStreamMap.clear();
    }

    public void resetSource() throws IOException {
        initSampleSource();
        initIndividualList();
        useSampleSource = true;
    }

    public void handleFileUpload(FileUploadEvent event) throws IOException {

        UploadedFile file = event.getFile();
        String fileName = file.getFileName().toLowerCase();
        fileStreamMap.put(fileName, file.getInputStream());
        
        if (fileStreamMap.size() == filesCount) {
            Collection<Path> filePathCollection = new ArrayList<>();
            for (Map.Entry<String, InputStream> entry : fileStreamMap.entrySet()) {
                try (InputStream inputStream = entry.getValue()) {
                    Path targetPath = tempFolderPath.resolve(entry.getKey());
                    FileUtil.storeFile(entry.getKey(), inputStream, targetPath);
                    filePathCollection.add(targetPath);
                }   
            }
            try (OutputStream outputStream = Files.newOutputStream(sourcePath)) {
                GenoProXmlMerger.merge(filePathCollection, outputStream);
            }
            for (Path filePath : filePathCollection) {
                Files.deleteIfExists(filePath);
            }

            initIndividualList();
            useSampleSource = false;
        }
    }

    public String generate() {

        try (OutputStream outputStream = Files.newOutputStream(ancestorTreePath)) {

            AncestorTreeGenerator.generate(sourcePath, currentId, outputStream);

        } catch (IOException e) {
            // pass faces message
        }

        try (OutputStream outputStream = Files.newOutputStream(finalPath)) {

            Map<String, Object> parameterMap = new HashMap<>();
            parameterMap.put("generations", generations);

            SvgRenderer.render(ancestorTreePath, parameterMap, outputStream);

        } catch (IOException e) {
            // pass faces message
        }

        return "/output/" + finalPath.getFileName().toString() + "?faces-redirect=true";
    }

    public Boolean getUseSampleSource() {
        return useSampleSource;
    }

    public List<SelectItem> getIndividualList() {
        return individualList;
    }

    public String getCurrentId() {
        return currentId;
    }

    public void setCurrentId(String currentId) {
        this.currentId = currentId;
    }

    public int getGenerations() {
        return generations;
    }

    public void setGenerations(int generations) {
        this.generations = generations;
    }
}
