# crec_scrape
crec_scrape is a respository that provides code to collect and tidy the daily editions of the U.S. Congressional Records from https://www.govinfo.gov/. Daily editions include text spoken on the floor of the Congress divided into four units: House of Representative, Senate, Daily Digest, and Extension of Remarks. By making the text accessible for R users, the purpose of this respository is to contribute to the understandability of congressional debates. 

## About the respository
The respository is the result of a group project within the [SPOSM](https://github.com/joachim-gassen/sposm) course of the Humboldt-University of Berlin and follows the following structure:

* `code:` contain code to scrape, tidy and visualize the data
* `output:` store scraped html-files
* `raw_data:` store processed datasets
* `plots:` contain different plots that have been produced to visualize data

## Basic Usage
This project is tested using R 3.6.2. and RStudio version 1.2.1335.

The general form to start the scraping and tidying process of U.S. Congressional Records is to [clone the respository](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository) and to open the file `master-sourcing-the-rest.R` from the code-directory. 
Here, you need to set up the working environment by installing required packages. The second step requires you to enter the `start_date` and `end_date` of the time period you want to download the Congressional Records for. The third step includes the actual scraping process by sourcing `1_scraper.R`. Thereby, the desired Congressional Records are downloaded as html-files and are stored in the directory output locally on your computer. From there, the tidying process can start. By sourcing `2_clean_html_files.R` the script parses the text from each html-file and produces a dataset called `my_data`. The dataset `my_data` is structured as follows: `vol`, `no`, and `date` identify the daily edition of the Congressional Records. `unit` identifies the four main sections of each edition, namely House, Senate, Daily Digest, and Extensions of Remarks. `pages`, `start_page`, `end_page` identifies associated page numbers for each unit in the edition and `text` contains the associated text. As the daily records are issued only when the congress is in session, a merging command introduce NA’s for dates when congress in not in session (e.g. weekends).

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
    <td>Every year, a new volume of the Congressional Records is started </td>
  </tr>
  <tr>
    <td>no</td>
    <td>Num</td>
    <td>Each day, a new issue of the Congressional Records is printed</td>
  </tr>
  <tr>
    <td>date</td>
    <td>Date</td>
    <td>Date of the Congressional Record in Format YYYY-MM-DD</td>
  </tr>
  <tr>
    <td>unit</td>
    <td>Factor</td>
    <td>The Congressional Records consist out of four sections: House, Senate, Daily Digest, and Extensions of Remark. While House and Senate contains all text spoken of the two chambers of the congress, Daily Digest serves as a table of content for the congress actions, and extension of remarks contains tributes, statements, and other information that are not directly spoken during open proceedings</td>
  </tr>
  <tr>
    <td>pages</td>
    <td>Factor</td>
    <td>Pages are numbered sequentially throughout the session of congress. The pageprefix operator helps to specify units by H, S, D and E.</td>
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
    <td>Shows the text of the congressional record associated with vol, no, date, and unit</td>
  </tr>
</table> 

## Data Visualization
The file `4_data_visualization.R` from the code-directory contains certain attemps to visualize the text, e.g. 
* by plotting the top 10 most frequent words of a certain unit in a certain period
* by creating wordclouds of a certain unit in a certain period
* by plotting the frequency of selected keywords over time of a certain unit 

## Contributing
Based on the data output we want to encourage the community to build analysis on congressional debates, to visualize their findings and to share them with us. Pull request are welcomed. Please read CONTRIBUTING.md for details on our code of conduct.
