[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3741898.svg)](https://doi.org/10.5281/zenodo.3741898)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)

# TELLme-vlab-elephantSkin
Shiny App for computing the "Elephant skin" (hillshade) of a given DEM

## About
Obtain and process Digital Elevation Model data with gdaldem algorithms and produce 'Elephant Skin' and 'Golden Map' to use as base layers of TELLme Metropolitan Cartography maps.

## Usage
1. Select the source DEM. You can select the following sources:
- (file) upload a tiff-image file
- (from API) select a bounding box (click on the black-square-icon control in the map and draw a rectangle), set the desired resolution, click the button to obtain the DEM from AWS Open Data Terrain Tiles API
2. Choose the desidered processing (mode) and tune the settings according to your needs. Click 'Compute and plot output map' button.
3. See the resulting output. When you are satisfied, click the "Download results" button to obtain the output raster (geotiff image)

### Usage with Docker

build the image:
   sudo docker build -t tellme-vlab-elephantskin:<version> .
run the container:
   sudo docker run -it --rm -p 3838:3838 tellme-vlab-elephantskin:<version>

(or use the precompiled image from docker.io 
   sudo docker run -p 80:3838 [ptagliolato/]tellme-vlab-elephantskin[:<version>]
   sudo docker pull ptagliolato/tellme-vlab-elephantskin:<version>
)
open your browser (if you are running the container in your machine) at the url:
   http://127.0.0.1:3838/



### Guidelines for metadata lineage field of downloaded files

Cite the source DEM file, the gdaldem algorithm you choose (hillshade or slope) and the present application (see credits section). 
If you choose the remote service source, please obtain licence information and citation instructions starting from the documentation at the url in point 1.
In fact, multiple sources concur to the DEM coverage, so the exact citation of original DEM data depends on the bounding box.

Elaboration of DEM from AWS Open Data Terrain Tiles API (https://registry.opendata.aws/terrain-tiles/). Elaborated with gdaldem algorithms through TELLme Project Virtual Lab tool (DOI: 10.5281/zenodo.3741898)

## Credits
Application developed within the TELLme ERASMUS+ project Gran Agreement Number:2017-1-IT02-KA203-036974, output O4. 

The application is being developed by Paolo Tagliolato and Alessandro Oggioni ([IREA-CNR](http://www.irea.cnr.it)). It is released under the [GNU General Public License version 3](https://www.gnu.org/licenses/gpl-3.0.html) (GPL‑3).

Please cite: DOI: 10.5281/zenodo.3741898

### Acknowledgements
The authors wish to acknowledge the contribution of Alessandro Musetta to the "Elephant Skin" app in its ideation phase.

#### Support contact
For support or suggestions you can use the GitHub Issue Tracker or via email (tagliolato.p(at)irea.cnr.it)
