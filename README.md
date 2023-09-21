# crec_scrape
crec_scrape is a respository that provides code to collect and tidy the daily editions of the U.S. Congressional Records from https://www.govinfo.gov/. Daily editions include text spoken on the floor of the Congress divided into four units: House of Representative, Senate, Daily Digest, and Extension of Remarks. By making our code available to R users, we hope to contribute to the accessibility of congressional debates and to the open science community. 

## About the respository
The respository is the result of a group project within the [SPOSM](https://github.com/joachim-gassen/sposm) course of the Humboldt-University of Berlin and follows the following structure:

* `code:` contains code to scrape, tidy and visualize the data
* `output:` store processed datasets
* `plots:` contains different plots that have been produced to visualize data for a presentation

## Basic Usage
This project is tested using R version 3.6.0 (2019-04-26), Platform: x86_64-w64-mingw32/x64 (64-bit), Running under: Windows 10 x64 (build 18362)

The general form to start the **scraping**, **tidying**, and **visualization** process of U.S. Congressional Records is to [clone the respository](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository) and to open the file `master-sourcing-the-rest.R` from the code-directory. Here, you need to set up in a first step the working environment by installing required packages. 

#### Scraping Process
In order to start the scraping process, the second step of the script requires you to enter the `start_date` and `end_date` of the time period you want to download the Congressional Records for. Then, by sourcing `1_scraper.R` the actual scraping process will be started. Thereby, the desired Congressional Records are downloaded as html-files and are stored in the directory output locally on your computer. 

#### Tidying Process
From there, the tidying process can start. By sourcing `2_clean_html_files.R`, the script parses the text from each html-file and produces a dataset called `my_data`. The dataset `my_data` is structured as follows: `vol`, `no`, and `date` identify the daily edition of the Congressional Records. `unit` identifies the four main sections of each edition, namely House, Senate, Daily Digest, and Extensions of Remarks. `pages`, `start_page`, `end_page` identify associated page numbers for each unit in the edition and `text` contains the associated text. For further details, please have a look at the data output section. As the daily records are issued only when the congress is in session, a merging command introduce NA’s for dates when congress is not in session (e.g. weekends).

#### Visualization Process
After creating the dataset `my_data`, the file `3_data_visualization.R` need to be sourced as it contains several plotting functions. Our script proposes the following ideas to visualize the text, e.g.

* plotting the number of characters over time by unit
* plotting the top 10 most frequent words of a certain unit in a certain period
* creating wordclouds of a certain unit in a certain period
* plotting the frequency of selected keywords over time of a certain unit
* plotting the use of negative and positive words over time by unit

## Data Output
 <table style="width:100%">
  <tr>
    <th>Variable</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>vol</td>
    <td>Num</td>
    <td>A new volume of the Congressional Records is started every year (e.g. Volumne 140 for 1994)</td>
  </tr>
  <tr>
    <td>no</td>
    <td>Num</td>
    <td>A new issue of the Congressional Records is printed every day </td>
  </tr>
  <tr>
    <td>date</td>
    <td>Date</td>
    <td>Date of the Congressional Record in Format YYYY-MM-DD</td>
  </tr>
  <tr>
    <td>unit</td>
    <td>Factor</td>
    <td>The Congressional Records consist out of four sections: House, Senate, Daily Digest, and Extensions of Remark. While House and Senate include all words spoken on the floor of the Congress, Daily Digest serves as a table of content for the Congress actions, and Extension of Remarks contains tributes, statements, and other information that are not directly spoken during open proceedings</td>
  </tr>
  <tr>
    <td>pages</td>
    <td>Factor</td>
    <td>Pages are numbered sequentially throughout the session of Congress. The pageprefix operator helps to specify units by H, S, D and E</td>
  </tr>
  <tr>
    <td>start_page</td>
    <td>Int</td>
    <td>Shows the page where the unit starts its text</td>
  </tr>
  <tr>
    <td>end_page</td>
    <td>Int</td>
    <td>Shows the page where the unit ends its text</td>
  </tr>
  <tr>
    <td>text</td>
    <td>Chr</td>
    <td>Contains the processed text </td>
  </tr>
</table> 

## Contributing
Based on the data output we want to encourage the community to build analysis on congressional debates, to visualize their findings and to share them with us. Pull request are therefore highly welcomed. Please read CONTRIBUTING.md for details on our code of conduct.
