import dash
from dash import dcc, html
import plotly.express as px
import plotly.graph_objects as go
import pandas as pd
import dash_bootstrap_components as dbc
import os
from google.cloud import storage

# Initialize Dash app
app = dash.Dash(__name__, external_stylesheets=[dbc.themes.BOOTSTRAP])
app.title = "Financial Reports"
server = app.server

def load_data_from_gcs():
    """Load financial data from Google Cloud Storage"""
    bucket_name = os.getenv('DATA_BUCKET')
    if not bucket_name:
        raise Exception("DATA_BUCKET environment variable not set")

    # Load from GCS
    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob('dashboards/financial_data.csv')

    # Download to temp file
    blob.download_to_filename('/tmp/financial_data.csv')
    return pd.read_csv('/tmp/financial_data.csv')

# Load financial data
financial_df = load_data_from_gcs()

# Create navbar
navbar = dbc.NavbarSimple(
    children=[
        dbc.NavItem(dbc.NavLink("Financial Reports", href="/", active=True)),
    ],
    brand="Analytics Platform - Finance",
    brand_href="/",
    color="info",
    dark=True,
    className="mb-4"
)

# Revenue vs Budget
revenue_fig = go.Figure()
revenue_fig.add_trace(go.Scatter(x=financial_df['month'], y=financial_df['revenue'],
                        mode='lines+markers', name='Actual Revenue'))
revenue_fig.add_trace(go.Scatter(x=financial_df['month'], y=financial_df['budget_revenue'],
                        mode='lines+markers', name='Budget Revenue'))
revenue_fig.update_layout(title="Revenue: Actual vs Budget")

# Profit trend
profit_fig = px.line(financial_df, x='month', y='profit',
                    title="Monthly Profit Trend")

# Expenses breakdown
expense_comparison = go.Figure()
expense_comparison.add_trace(go.Bar(x=financial_df['month'], y=financial_df['expenses'],
                                  name='Actual Expenses'))
expense_comparison.add_trace(go.Bar(x=financial_df['month'], y=financial_df['budget_expenses'],
                                  name='Budget Expenses'))
expense_comparison.update_layout(title="Expenses: Actual vs Budget", barmode='group')

# Layout
app.layout = html.Div([
    navbar,
    dbc.Container([
        html.H3("Financial Performance Reports", className="mb-4"),

        # Key metrics cards
        dbc.Row([
            dbc.Col([
                dbc.Card([
                    dbc.CardBody([
                        html.H5("Total Revenue", className="card-title"),
                        html.H3(f"${financial_df['revenue'].sum():,.0f}", className="text-success")
                    ])
                ])
            ], width=4),
            dbc.Col([
                dbc.Card([
                    dbc.CardBody([
                        html.H5("Total Profit", className="card-title"),
                        html.H3(f"${financial_df['profit'].sum():,.0f}", className="text-primary")
                    ])
                ])
            ], width=4),
            dbc.Col([
                dbc.Card([
                    dbc.CardBody([
                        html.H5("Profit Margin", className="card-title"),
                        html.H3(f"{(financial_df['profit'].sum() / financial_df['revenue'].sum() * 100):.1f}%", className="text-info")
                    ])
                ])
            ], width=4)
        ], className="mb-4"),

        # Charts
        dbc.Row([
            dbc.Col([dcc.Graph(figure=revenue_fig)], width=12)
        ]),
        dbc.Row([
            dbc.Col([dcc.Graph(figure=profit_fig)], width=6),
            dbc.Col([dcc.Graph(figure=expense_comparison)], width=6)
        ])
    ], fluid=True)
])

if __name__ == '__main__':
    port = int(os.getenv('PORT', 8050))
    app.run_server(debug=False, host='0.0.0.0', port=port)
