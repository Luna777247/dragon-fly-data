import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from pathlib import Path
import numpy as np

# Load data
data_path = Path(r"d:\project\dragon-fly-data\src\data\vietnam_advance.csv")
df = pd.read_csv(data_path)

# Page config
st.set_page_config(page_title="Vietnam Data Story - Streamlit Dashboard", layout="wide")

# Title
st.title("Vietnam Data Story - Comprehensive Analysis Dashboard")
st.markdown("Aggregated results from Jupyter notebooks analysis")

# Sidebar navigation
st.sidebar.title("Analysis Sections")
section = st.sidebar.radio("Choose Analysis", [
    "Overview",
    "Historical Trends",
    "Economic Forecasting",
    "Policy Research",
    "Social Forecasting",
    "Data Visualization",
    "Population Forecasting"
])

if section == "Overview":
    st.header("Overview of Vietnam's Development (1955-2025)")
    st.markdown("""
    This dashboard aggregates key insights from various data analyses:
    - Historical trends over 70 years
    - Economic forecasting models
    - Policy impact assessments
    - Social development projections
    - Interactive data visualizations
    """)
    
    # Basic stats
    col1, col2, col3 = st.columns(3)
    with col1:
        st.metric("Years Covered", f"{len(df)} years")
    with col2:
        st.metric("Data Points", f"{len(df) * len(df.columns)} total")
    with col3:
        st.metric("Indicators", f"{len(df.columns)} variables")

elif section == "Historical Trends":
    st.header("Historical Trends Analysis")
    st.markdown("Analysis of Vietnam's socioeconomic development over time")
    
    # GDP Trend
    if 'gdpBillion' in df.columns:
        fig = px.line(df, x='year', y='gdpBillion', title='GDP Growth Over Time')
        st.plotly_chart(fig)
    
    # Population
    if 'population' in df.columns:
        fig = px.line(df, x='year', y='population', title='Population Growth')
        st.plotly_chart(fig)

elif section == "Economic Forecasting":
    st.header("Economic Forecasting")
    st.markdown("GDP forecasting models and scenarios")
    
    # Placeholder for forecasting charts
    st.info("Economic forecasting analysis would include:")
    st.markdown("- Conservative, moderate, and optimistic GDP scenarios")
    st.markdown("- Model comparison and validation")
    st.markdown("- Key economic indicators projections")
    
    # Simple projection if data available
    if 'gdpBillion' in df.columns:
        recent_years = df[df['year'] >= 2000]
        fig = px.scatter(recent_years, x='year', y='gdpBillion', trendline="ols", 
                        title='GDP Trend with Linear Projection')
        st.plotly_chart(fig)

elif section == "Policy Research":
    st.header("Policy Research Analysis")
    st.markdown("Evaluating policy impacts across different periods")
    
    st.info("Policy research would analyze:")
    st.markdown("- Correlation between policies and development indicators")
    st.markdown("- Impact assessment of major reforms")
    st.markdown("- Comparative analysis across time periods")
    
    # Correlation heatmap if multiple indicators
    numeric_cols = df.select_dtypes(include=[float, int]).columns
    if len(numeric_cols) > 2:
        corr = df[numeric_cols].corr()
        fig = px.imshow(corr, title='Correlation Matrix of Key Indicators')
        st.plotly_chart(fig)

elif section == "Social Forecasting":
    st.header("Social Forecasting")
    st.markdown("Projections for social indicators to 2050")
    
    st.info("Social forecasting includes:")
    st.markdown("- Population and urbanization projections")
    st.markdown("- Health and education indicators")
    st.markdown("- Social development scenarios")
    
    # Urbanization if available
    if 'urbanPopulationPercent' in df.columns:
        fig = px.line(df, x='year', y='urbanPopulationPercent', 
                     title='Urban Population Percentage Trend')
        st.plotly_chart(fig)

elif section == "Data Visualization":
    st.header("Interactive Data Visualization")
    st.markdown("Comprehensive charts and dashboards")
    
    # Multi-chart dashboard
    col1, col2 = st.columns(2)
    
    with col1:
        # Scatter plot
        if len(df.select_dtypes(include=[float, int]).columns) >= 2:
            x_col = st.selectbox("X-axis", df.select_dtypes(include=[float, int]).columns, key='x')
            y_col = st.selectbox("Y-axis", df.select_dtypes(include=[float, int]).columns, key='y')
            fig = px.scatter(df, x=x_col, y=y_col, title=f'{y_col} vs {x_col}')
            st.plotly_chart(fig)
    
    with col2:
        # Bar chart for latest year
        latest_year = df['year'].max()
        latest_data = df[df['year'] == latest_year].select_dtypes(include=[float, int]).iloc[0]
        # Select top 10 indicators
        top_indicators = latest_data.nlargest(10)
        fig = px.bar(x=top_indicators.index, y=top_indicators.values, 
                     title=f'Top 10 Key Indicators for {latest_year}')
        st.plotly_chart(fig)

elif section == "Population Forecasting":
    st.header("Population Forecasting - Factors Influencing Vietnam's Population")
    st.markdown("Analysis of factors affecting population growth and forecasting models")
    
    # Qualitative factors section
    st.subheader("Key Factors Influencing Population")
    col1, col2, col3 = st.columns(3)
    
    with col1:
        st.info("**Birth Rate**\n\nNatural population growth driver")
        st.info("**Death Rate**\n\nAffects population dynamics")
    
    with col2:
        st.info("**Economic Factors**\n\nSocioeconomic development impact")
        st.info("**Population Structure**\n\nAge distribution effects")
    
    with col3:
        st.info("**Migration**\n\nInternal and international movement")
        st.info("**Government Policies**\n\nBirth limitation and family planning")
    
    # Quantitative forecasting section
    st.subheader("Population Forecasting Models")
    
    # Create forecast data (simulated)
    historical_years = df['year'].values
    historical_pop = df['population'].values / 1000000  # Convert to millions
    
    # Forecast years
    forecast_years = list(range(2025, 2066))
    
    # Simulated forecasts using different models
    import numpy as np
    
    # Simple exponential growth
    last_pop = historical_pop[-1]
    exp_growth = [last_pop * (1.005 ** (i+1)) for i in range(len(forecast_years))]
    
    # Logistic growth (simplified)
    carrying_capacity = 120  # millions
    logistic_growth = []
    current = last_pop
    for i in range(len(forecast_years)):
        growth_rate = 0.01 * (1 - current/carrying_capacity)
        current = current * (1 + growth_rate)
        logistic_growth.append(current)
    
    # Gompertz growth (simplified)
    gompertz_growth = []
    current = last_pop
    for i in range(len(forecast_years)):
        growth_rate = 0.015 * np.exp(-0.01 * i)
        current = current * (1 + growth_rate)
        gompertz_growth.append(current)
    
    # Create combined chart
    fig = go.Figure()
    
    # Historical bars (population by year)
    fig.add_trace(go.Bar(
        x=historical_years,
        y=historical_pop,
        name='Historical Population',
        marker_color='lightblue',
        opacity=0.7
    ))
    
    # Forecast lines
    all_years = historical_years.tolist() + forecast_years
    
    # Exponential
    fig.add_trace(go.Scatter(
        x=all_years,
        y=historical_pop.tolist() + exp_growth,
        mode='lines',
        name='Exponential Forecast',
        line=dict(color='red', dash='dash')
    ))
    
    # Logistic
    fig.add_trace(go.Scatter(
        x=all_years,
        y=historical_pop.tolist() + logistic_growth,
        mode='lines',
        name='Logistic Forecast',
        line=dict(color='green', dash='dot')
    ))
    
    # Gompertz
    fig.add_trace(go.Scatter(
        x=all_years,
        y=historical_pop.tolist() + gompertz_growth,
        mode='lines',
        name='Gompertz Forecast',
        line=dict(color='orange', dash='dashdot')
    ))
    
    fig.update_layout(
        title='Vietnam Population: Historical Data and Forecasting Models (1955-2065)',
        xaxis_title='Year',
        yaxis_title='Population (Millions)',
        showlegend=True,
        height=600
    )
    
    st.plotly_chart(fig)
    
    st.markdown("""
    **Forecasting Models:**
    - **Exponential**: Constant growth rate
    - **Logistic**: Growth slows as population approaches carrying capacity
    - **Gompertz**: Growth rate decreases exponentially over time
    
    *Data sources: World Bank, UN Population Prospects, simulated projections*
    """)

# Footer
st.markdown("---")
st.markdown("Dashboard generated from Vietnam development data analysis")