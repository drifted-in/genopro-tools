GenoPro tools
=============

Web application for genealogists that allows to generate reports from separate GenoPro files. 

Currently only Ancestor Tree report is available. You can see it [in action](http://drifted.in/genopro-tools-app/).

How to build
============
  * Clone this repository to your local disc.
  * Ensure that JDK 7+ is available on your system.
  * Open this Maven based project in your favorite IDE.
  * Build project.
  * Deploy the final war file into Java Servlet 3.0+ container, e.g. Apache Tomcat 8.

How it works
============
  1. Uploaded data (if needed) is converted into GenoPro XML files.
     * GenoPro XML files can be uploaded as well, they are passed for further processing directly.
     * GenoPro GNO files are just compressed XML files with GNO extension.

  2. If multiple data files are specified, they are [merged](src/main/resources/in/drifted/tools/genopro/templates/merge.xslt) into a single XML file.
     * This merged file contains just elements required for further processing.
     * It has modified IDs to avoid clashes.
     * It is not compatible with GenoPro XML format any more.

  3. In case of Ancestor Tree the source data is [transformed](src/main/resources/in/drifted/tools/genopro/templates/ancestor-tree.xslt) into a custom XML tree that contains all ancestors of selected individual.
     * This custom XML format contains just basic info about each individual.
     * If separate family trees are hyperlinked in the original source files, they are treated as a single continuous tree.
     * The result is a ideal base for various outputs, even graphical, see the next step.

  4. In case of Ancestor Tree the final XML file is [transformed](src/main/resources/in/drifted/tools/genopro/templates/svg.xslt) into SVG chart.
     * In the web application there is the only option 'Generations', which can be set up to 8.
     * Template itself supports other ones:
         * width - by default `420` (width of A3 paper size, the height is half of the width)
         * units - by default `mm` (millimeters)
         * font-size - by default calculated automatically
         * font-family - by default `sans-serif`
         * grid-color - by default `navy`
     * There is no support for them in web application as it is expected the output will be modified anyway (e.g. in [Inkscape](https://inkscape.org/)).

Notes
=====
Most of steps is based on XSLT tranformations and they can be of course executed directly using XSLT 2.0 processor. 
This web application just simplifies all the configuration and manual steps.