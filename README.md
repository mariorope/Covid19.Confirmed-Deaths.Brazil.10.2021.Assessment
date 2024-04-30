<h3>Title: Exploratory analysis of Covid19 cases and deaths in Brazil</h3><br>

**Introduction:**

<p align="justify">This project conducts a thorough exploration and analysis of COVID-19 data related to cases and deaths across Brazil, covering the period from early 2020 to early 2022. The analysis solely utilizes R for data preprocessing, manipulation, and visualisation, aiming to identify key patterns and insights into the pandemic's impact across different Brazilian regions.</p>

**Data Source:**

<p align="justify">The dataset, sourced from an official Brazilian database, provides detailed records from epidemiological reports across the country.</p>

**Data Preprocessing:**

<p align="justify">The initial step involves cleaning and preparing the data for analysis using R, focusing on selecting necessary variables and correcting data discrepancies.</p>

**Exploratory Data Analysis:**

<p align="justify">Deep dive into the data using statistical techniques and visualisations to uncover temporal and regional trends in case and death rates.</p>

**Key Findings:**

<ol>
<li>The analysis reveals significant regional differences in the impact of COVID-19 and the effectiveness of response measures.</li>
<li>Temporal trends indicate critical periods of infection spread and mortality rates.</li>
</ol>

**Conclusion:**

<p align="justify">The findings underscore the importance of tailored public health responses and provide valuable insights for policymakers and health professionals.</p>

**Dictionary of Variables**

<ul>
  <li><span style='font-weight: bold'>city:</span> name of the municipality (can be blank when the record refers to the state, it can be filled in with Imported/Undefined as well).</li>
  <li><span style='font-weight: bold'>city_ibge_code:</span> IBGE code for the location.</li>
  <li><span style='font-weight: bold'>date:</span> data collection date in YYYY-MM-DD format.</li>
  <li><span style='font-weight: bold'>epidemiological_week:</span> epidemiological week number in YYYYWW format.</li>
  <li><span style='font-weight: bold'>estimated_population:</span> estimated population for this municipality/state in 2020, according to IBGE.</li>
  <li><span style='font-weight: bold'>estimated_population_2019:</span> estimated population for this municipality/state in 2019, according to IBGE. ATTENTION: this column has outdated values, prefer to use the estimated_population column.</li>
  <li><span style='font-weight: bold'>is_last:</span> pre-computed field that says whether this record is the newest for this location, can be True or False (if you filter by this field, use is_last=True or is_last=False, do not use the lowercase value).</li>
  <li><span style='font-weight: bold'>is_repeated:</span> pre-computed field that says whether this record is the newest for this location, can be True or False (if you filter by this field, use is_last=True or is_last=False, do not use the lowercase value).</li>
  <li><span style='font-weight: bold'>last_available_confirmed:</span> number of confirmed cases on the last available day equal to or before the date.</li>
  <li><span style='font-weight: bold'>last_available_confirmed_per_100k_inhabitants:</span> number of confirmed cases per 100,000 inhabitants (based on estimated_population) from the last available day on or before the date.</li>
  <li><span style='font-weight: bold'>last_available_date:</span> date to which the data refers.</li>
  <li><span style='font-weight: bold'>last_available_death_rate:</span> mortality rate (deaths/confirmed) of the last available day equal to or before the date date.</li>
  <li><span style='font-weight: bold'>last_available_deaths:</span> number of deaths from the last available day equal to or before the date.</li>
  <li><span style='font-weight: bold'>order_for_place:</span> number that identifies the registration order for this location. The record referring to the first bulletin in which this location appears will be counted as 1 and the other bulletins will increase this value.</li>
  <li><span style='font-weight: bold'>place_type:</span> type of location that this record describes, it can be city or state.</li>
  <li><span style='font-weight: bold'>state:</span> acronym of the federative unit, example: SP.</li>
  <li><span style='font-weight: bold'>new_confirmed:</span> number of new cases confirmed since the last day (note that if is_repeated is True, this value will always be 0 and that this value may be negative if the SES relocates cases from that municipality to another).</li>
  <li><span style='font-weight: bold'>new_deaths:</span> number of new deaths since the last day (note that if is_repeated is True, this value will always be 0 and that this value may be negative if the SES relocates cases from that municipality to another).</li>
</ul>




