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

import in.drifted.util.StringUtil;
import in.drifted.util.Xslt20ProcessorUtil;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class GenoProXmlMerger {

    private static final String XSLT_MERGE = Constants.RESOURCES_PATH + "templates/merge.xsl";

    public static void merge(Collection<Path> filePathCollection, OutputStream outputStream) throws IOException {

        if (!filePathCollection.isEmpty()) {

            List<String> fileNameList = new ArrayList<>();

            Iterator<Path> iterator = filePathCollection.iterator();

            Path sourcePath = iterator.next();

            fileNameList.add(sourcePath.toUri().toString());

            while (iterator.hasNext()) {
                fileNameList.add(iterator.next().toUri().toString());
            }

            try (
                    InputStream xsltInputStream = GenoProXmlMerger.class.getResourceAsStream(XSLT_MERGE);
                    InputStream xmlInputStream = Files.newInputStream(sourcePath)) {

                Map<String, Object> parameterMap = new HashMap<>();
                parameterMap.put("parts", StringUtil.getDelimitedCollection(fileNameList, ";"));

                Xslt20ProcessorUtil.transform(xsltInputStream, xmlInputStream, outputStream, parameterMap);
            }
        }
    }
}
