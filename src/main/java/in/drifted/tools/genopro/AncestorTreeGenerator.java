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

import in.drifted.tools.xslt.Transformer;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;

public class AncestorTreeGenerator {

    private static final String XSLT_ANCESTOR_TREE = Constants.RESOURCES_PATH + "templates/ancestor-tree.xsl";

    public static void generate(Path sourcePath, String baseId, OutputStream outputStream) throws IOException {

        try (
                InputStream xsltInputStream = AncestorTreeGenerator.class.getResourceAsStream(XSLT_ANCESTOR_TREE);
                InputStream xmlInputStream = Files.newInputStream(sourcePath)) {

            Map<String, Object> parameterMap = new HashMap<>();
            parameterMap.put("baseId", baseId);

            Transformer.transform(xsltInputStream, xmlInputStream, outputStream, parameterMap);
        }
    }
}
