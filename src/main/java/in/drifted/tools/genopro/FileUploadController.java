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
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Collection;
import java.util.HashSet;

import org.primefaces.event.FileUploadEvent;
import org.primefaces.model.UploadedFile;

public class FileUploadController {

    private static Path tempFolderPath;

    public FileUploadController() throws IOException {
        tempFolderPath = Files.createTempDirectory(FileUploadController.class.getName()).toAbsolutePath();
    }

    public void storeFile(FileUploadEvent event) throws IOException {

        UploadedFile uploadedFile = event.getFile();
        String fileName = uploadedFile.getFileName().toLowerCase();

        try (InputStream inputStream = uploadedFile.getInputstream()) {

            Path targetPath = Files.createFile(tempFolderPath.resolve(fileName));

            FileUtil.storeFile(fileName, inputStream, targetPath);
        }
    }

    public Collection<Path> getFilePathCollection() {

        Collection<Path> filePathCollection = new HashSet<>();

        try (DirectoryStream<Path> directoryStream = Files.newDirectoryStream(tempFolderPath)) {

            for (Path path : directoryStream) {
                filePathCollection.add(path);
            }

        } catch (IOException e) {
        }

        return filePathCollection;
    }

    public Path getTempFolderPath() {
        return tempFolderPath;
    }
}
