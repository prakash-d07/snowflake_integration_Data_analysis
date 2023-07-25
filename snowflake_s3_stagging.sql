// create Database for analysis

create database covid_analysis

//creating table schema

CREATE TABLE `CovidDeaths` (
	iso_code VARCHAR(8) NOT NULL, 
	continent VARCHAR(13), 
	location VARCHAR(32) NOT NULL, 
	date DATE NOT NULL, 
	total_cases DECIMAL(38, 0), 
	new_cases DECIMAL(38, 0), 
	new_cases_smoothed DECIMAL(38, 3), 
	total_deaths DECIMAL(38, 0), 
	new_deaths DECIMAL(38, 0), 
	new_deaths_smoothed DECIMAL(38, 3), 
	total_cases_per_million DECIMAL(38, 3), 
	new_cases_per_million DECIMAL(38, 3), 
	new_cases_smoothed_per_million DECIMAL(38, 3), 
	total_deaths_per_million DECIMAL(38, 3), 
	new_deaths_per_million DECIMAL(38, 3), 
	new_deaths_smoothed_per_million DECIMAL(38, 3), 
	reproduction_rate DECIMAL(38, 2), 
	icu_patients DECIMAL(38, 0), 
	icu_patients_per_million DECIMAL(38, 3), 
	hosp_patients DECIMAL(38, 0), 
	hosp_patients_per_million DECIMAL(38, 3), 
	weekly_icu_admissions DECIMAL(38, 3), 
	weekly_icu_admissions_per_million DECIMAL(38, 3), 
	weekly_hosp_admissions DECIMAL(38, 3), 
	weekly_hosp_admissions_per_million DECIMAL(38, 3), 
	new_tests DECIMAL(38, 0), 
	total_tests DECIMAL(38, 0), 
	total_tests_per_thousand DECIMAL(38, 3), 
	new_tests_per_thousand DECIMAL(38, 3), 
	new_tests_smoothed DECIMAL(38, 0), 
	new_tests_smoothed_per_thousand DECIMAL(38, 3), 
	positive_rate DECIMAL(38, 3), 
	tests_per_case DECIMAL(38, 1), 
	tests_units VARCHAR(15), 
	total_vaccinations DECIMAL(38, 0), 
	people_vaccinated DECIMAL(38, 0), 
	people_fully_vaccinated DECIMAL(38, 0), 
	new_vaccinations DECIMAL(38, 0), 
	new_vaccinations_smoothed DECIMAL(38, 0), 
	total_vaccinations_per_hundred DECIMAL(38, 2), 
	people_vaccinated_per_hundred DECIMAL(38, 2), 
	people_fully_vaccinated_per_hundred DECIMAL(38, 2), 
	new_vaccinations_smoothed_per_million DECIMAL(38, 0), 
	stringency_index DECIMAL(38, 2), 
	population DECIMAL(38, 0), 
	population_density DECIMAL(38, 3), 
	median_age DECIMAL(38, 1), 
	aged_65_older DECIMAL(38, 3), 
	aged_70_older DECIMAL(38, 3), 
	gdp_per_capita DECIMAL(38, 3), 
	extreme_poverty DECIMAL(38, 1), 
	cardiovasc_death_rate DECIMAL(38, 3), 
	diabetes_prevalence DECIMAL(38, 2), 
	female_smokers DECIMAL(38, 3), 
	male_smokers DECIMAL(38, 3), 
	handwashing_facilities DECIMAL(38, 3), 
	hospital_beds_per_thousand DECIMAL(38, 3), 
	life_expectancy DECIMAL(38, 2), 
	human_development_index DECIMAL(38, 3)
);

CREATE TABLE `CovidVaccinations` (
	iso_code VARCHAR(8) NOT NULL, 
	continent VARCHAR(13), 
	location VARCHAR(32) NOT NULL, 
	date DATE NOT NULL, 
	new_tests DECIMAL(38, 0), 
	total_tests DECIMAL(38, 0), 
	total_tests_per_thousand DECIMAL(38, 3), 
	new_tests_per_thousand DECIMAL(38, 3), 
	new_tests_smoothed DECIMAL(38, 0), 
	new_tests_smoothed_per_thousand DECIMAL(38, 3), 
	positive_rate DECIMAL(38, 3), 
	tests_per_case DECIMAL(38, 1), 
	tests_units VARCHAR(15), 
	total_vaccinations DECIMAL(38, 0), 
	people_vaccinated DECIMAL(38, 0), 
	people_fully_vaccinated DECIMAL(38, 0), 
	new_vaccinations DECIMAL(38, 0), 
	new_vaccinations_smoothed DECIMAL(38, 0), 
	total_vaccinations_per_hundred DECIMAL(38, 2), 
	people_vaccinated_per_hundred DECIMAL(38, 2), 
	people_fully_vaccinated_per_hundred DECIMAL(38, 2), 
	new_vaccinations_smoothed_per_million DECIMAL(38, 0), 
	stringency_index DECIMAL(38, 2), 
	population_density DECIMAL(38, 3), 
	median_age DECIMAL(38, 1), 
	aged_65_older DECIMAL(38, 3), 
	aged_70_older DECIMAL(38, 3), 
	gdp_per_capita DECIMAL(38, 3), 
	extreme_poverty DECIMAL(38, 1), 
	cardiovasc_death_rate DECIMAL(38, 3), 
	diabetes_prevalence DECIMAL(38, 2), 
	female_smokers DECIMAL(38, 3), 
	male_smokers DECIMAL(38, 3), 
	handwashing_facilities DECIMAL(38, 3), 
	hospital_beds_per_thousand DECIMAL(38, 3), 
	life_expectancy DECIMAL(38, 2), 
	human_development_index DECIMAL(38, 3)
);



// Create storage integration object

create or replace storage integration s3_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE 
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::892694947397:role/aws_s3_snowflake_int'
  STORAGE_ALLOWED_LOCATIONS = ('s3://prax-test-01/', 's3://prax-test-01/')
  COMMENT = 'Integration with aws s3 buckets' ;


// Get external_id and update it in S3

DESC integration s3_int;

// Create  database  schemas

CREATE SCHEMA IF NOT EXISTS COVID_ANALYSIS.file_formats;

CREATE SCHEMA IF NOT EXISTS COVID_ANALYSIS.external_stages;



// create file format object

CREATE OR REPLACE file format COVID_ANALYSIS.FILE_FORMATS.csv_fileformat
    type = csv
    field_delimiter = ','
    skip_header = 1
    empty_field_as_null = TRUE;  



// Create stage object with integration object & file format object

CREATE OR REPLACE STAGE COVID_ANALYSIS.external_stages.aws_s3_csv
    URL = 's3://prax-test-01/'
    STORAGE_INTEGRATION = s3_int
    FILE_FORMAT = COVID_ANALYSIS.FILE_FORMATS.csv_fileformat ;



//Listing files under your s3 buckets

list @COVID_ANALYSIS.external_stages.aws_s3_csv;

// Use Copy command to load the files

COPY INTO COVID_ANALYSIS.PUBLIC."`COVIDDEATHS`"
    FROM @COVID_ANALYSIS.external_stages.aws_s3_csv
    PATTERN = '.*CovidDeaths.*';    

COPY INTO COVID_ANALYSIS.PUBLIC."`COVIDVACCINATIONS`"
    FROM @COVID_ANALYSIS.external_stages.aws_s3_csv
    PATTERN = '.*CovidVaccinations.*'; 




//Validate the data

select * from COVID_ANALYSIS.PUBLIC."`COVIDDEATHS`"

select * from COVID_ANALYSIS.PUBLIC."`COVIDVACCINATIONS`"



