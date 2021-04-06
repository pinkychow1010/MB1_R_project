# MB2-Final-Project
This Script is written as a semester project for the Programming and Geostatistical Analysis course [MB2](http://eagle-science.org/project/programming-and-geostatistical-analysis/) within the MSc. degree [MSc. in Applied Earth Observation and Geoanalysis (EAGLE)](http://eagle-science.org/) at [JMU Würzburg](https://www.uni-wuerzburg.de/en/home/).

The aim of this project is to generate interactive visuals of illegal gold mining in Munduruku using different types of earth observation data.

# **Temporal Dynamics of Gold Mining in Munduruku (Pará) Indigenous Reserves, Brazil**
In this repository you will find the analysis of gold mining temporal dynamics in Munduruku Indigenous Reserves between 2018 and 2020 based on Landsat-8 and Sentinel-1 data. An overview of the global forest changes are visualized in the Shiny app application. The data can be downloaded from the [google_drive](https://drive.google.com/drive/folders/18hPjrm3ap7YDglCAnNgnpVhuAhzhrtN9?usp=sharing). The Landsat data can also be downloaded from online platforms with the following product ID: LC08_L2SP_228065_20180626_20200831_02_T1, LC08_L2SP_228065_20190731_20200827_02_T1, and LC08_L2SP_228065_20200903_20200918_02_T1. The Sentinel-1 data analysis is achieved through rgee package and no data download is required. The final results consists of interactive maps of deforested area in different years and a [shiny_app](https://eagle-rproject-globalforestchanges.shinyapps.io/globalForestChanges/). It visualized time series of forest cover in different countries in the world using data published by FAO: [forest_area](https://data.worldbank.org/indicator/AG.LND.FRST.K2) in csv format. The aim of this code is to extract information from multitemporal remote sensing data in the region of interest to look into the scale of illegal mining development in the last two years (2018 - 2020).

## **1.Landsat-8**

In this section the downloaded Landsat data is preprocessed, and spectral indexes, NDVI and NDWI are calculated from the data. Statistical analysis, including Tasseled Cap Analysis and Change Vector Analysis are performed to investigate the characteristics of the mining development, which can be identified from both mining pool and cleared land. Deforestation area are finally derived from dNDVI visualized in an interactive map.

![dndvi](https://github.com/pinkychow1010/MB1_R_project/blob/master/example_output/dndvi.png)

## **2.Sentinel-1**

In this section forest disturbance analysis is performed using Sentinel-1 GRD back-scatter data assessed via rgee package. Threshold is developed to derive forest land cleared between 2018 and 2020.

![S1](https://github.com/pinkychow1010/MB1_R_project/blob/master/example_output/s1_deforestation.JPG)

## **3.ShinyApp**

In this section a Shiny app is developed to visualize global deforestation hotspots and forest-area-time-series for individual countries by clicking on a vector map.

![app](https://github.com/pinkychow1010/MB1_R_project/blob/master/example_output/app.png)


## Author
Ka Hei Chow MSc. Student in [Applied Earth Observation and Geoanalysis (EAGLE)](http://eagle-science.org/)
Linkedin: https://www.linkedin.com/in/ka-hei-chow-231345188/) E-mail: ka-hei-pinky.chow@stud-mail.uni-wuerzburg.de

## References
[C Aybar, Q Wu, L Bautista, R Yali and A Barja (2020) rgee: An R package for interacting with Google Earth Engine Journal of Open Source Software.](https://github.com/r-spatial/rgee/)

Forest Area. (2018). Retrieved April 6, 2021, from https://data.worldbank.org/indicator/AG.LND.FRST.ZS

Gorelick, N., Hancher, M., Dixon, M., Ilyushchenko, S., Thau, D., & Moore, R. (2017). Google Earth Engine: Planetary-scale geospatial analysis for everyone.
