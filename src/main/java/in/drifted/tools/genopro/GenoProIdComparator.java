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

import java.util.Comparator;
import javax.faces.model.SelectItem;

public class GenoProIdComparator implements Comparator<SelectItem> {

    @Override
    public int compare(SelectItem o1, SelectItem o2) {

        String id01 = o1.getValue().toString();
        String id02 = o2.getValue().toString();

        int result = getPrefix(id01).compareTo(getPrefix(id02));

        if (result == 0) {
            result = getNumber(id01).compareTo(getNumber(id02));
        }

        return result;
    }

    private String getPrefix(String id) {
        return id.split("ind")[0];
    }

    private Integer getNumber(String id) {
        return Integer.parseInt(id.split("ind")[1]);
    }
}
