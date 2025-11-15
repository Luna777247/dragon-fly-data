# Vietnam Data Story - Streamlit Dashboard

This Streamlit application aggregates and visualizes results from the Jupyter notebook analyses in the Vietnam Data Story project.

## Features

- **Overview**: Summary statistics and project overview
- **Historical Trends**: Long-term socioeconomic development analysis
- **Economic Forecasting**: GDP projections and economic scenarios
- **Policy Research**: Policy impact assessments and correlations
- **Social Forecasting**: Social indicators projections to 2050
- **Data Visualization**: Interactive charts and dashboards

## Setup

1. Navigate to the streamlit_app directory:
   ```bash
   cd streamlit_app
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run the application:
   ```bash
   streamlit run app.py
   ```

The app will open in your default browser at `http://localhost:8501`

## Data Source

The dashboard uses data from `../src/data/vietnam_advance.csv`, which contains 72 socioeconomic indicators for Vietnam from 1955-2025.

## Note

This is a complementary visualization tool to the main React application. It provides quick access to key insights from the notebook analyses without requiring Jupyter environment.