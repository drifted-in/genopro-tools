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

import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.zip.ZipInputStream;

public class FileUtil {

    public static void storeFile(String fileName, InputStream inputStream, Path targetPath) throws IOException {

        if (fileName == null) {
            fileName = targetPath.toString();
        }

        String extension = fileName.substring(fileName.lastIndexOf("."));

        switch (extension) {

            case ".gno": {

                try (ZipInputStream zipInputStream = new ZipInputStream(inputStream)) {

                    while (zipInputStream.getNextEntry() != null) {
                        storeFile(zipInputStream, targetPath);
                    }
                }
                
                break;
            }

            case ".xml": {
                storeFile(inputStream, targetPath);
                break;
            }
        }
    }

    private static void storeFile(InputStream inputStream, Path filePath) throws IOException {

        try (BufferedOutputStream outputStream = new BufferedOutputStream(Files.newOutputStream(filePath))) {

            byte[] buffer = new byte[32 * 1024];
            int bytesRead;

            while ((bytesRead = inputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, bytesRead);
            }
        }
    }
}
