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
package in.drifted.util;

import java.io.InputStream;
import java.io.OutputStream;
import java.util.Map;
import java.util.Map.Entry;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

public class Xslt20ProcessorUtil {

    public static boolean transform(InputStream xsltInputStream, InputStream xmlInputStream, OutputStream outputStream, Map<String, Object> parameterMap) {

        boolean result = false;

        try {
            
            Source source = new StreamSource(xsltInputStream);
            Transformer transformer = TransformerFactory.newInstance().newTemplates(source).newTransformer();

            for (Entry<String, Object> entry : parameterMap.entrySet()) {
                transformer.setParameter(entry.getKey(), entry.getValue());
            }

            transformer.transform(new StreamSource(xmlInputStream), new StreamResult(outputStream));

            result = true;

        } catch (TransformerException | TransformerFactoryConfigurationError e) {
        }

        return result;
    }
}
