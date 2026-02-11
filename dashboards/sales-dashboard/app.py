import dash
from dash import dcc, html
import plotly.express as px
import pandas as pd
import dash_bootstrap_components as dbc
import os
from google.cloud import storage

# Initialize Dash app
app = dash.Dash(__name__, external_stylesheets=[dbc.themes.BOOTSTRAP])
app.title = "Sales Dashboard"
server = app.server

def load_data_from_gcs():
    """Load sales data from Google Cloud Storage"""
    bucket_name = os.getenv('DATA_BUCKET')
    if not bucket_name:
        raise Exception("DATA_BUCKET environment variable not set")

    # Load from GCS
    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob('dashboards/sales_data.csv')

    # Download to temp file
    blob.download_to_filename('/tmp/sales_data.csv')
    return pd.read_csv('/tmp/sales_data.csv')

# Load sales data
sales_df = load_data_from_gcs()
sales_df['date'] = pd.to_datetime(sales_df['date'])

# Create navbar
navbar = dbc.NavbarSimple(
    children=[
        dbc.NavItem(dbc.NavLink("Sales Dashboard", href="/", active=True)),
    ],
    brand="Analytics Platform - Sales",
    brand_href="/",
    color="success",
    dark=True,
    className="mb-4"
)

# Revenue over time
monthly_sales = sales_df.groupby(['date', 'region'])['revenue'].sum().reset_index()
time_fig = px.line(monthly_sales, x='date', y='revenue', color='region',
                  title="Revenue Over Time by Region")

# Product performance
product_sales = sales_df.groupby('product')['revenue'].sum().reset_index()
product_fig = px.bar(product_sales, x='product', y='revenue',
                    title="Total Revenue by Product")

# Regional breakdown
region_sales = sales_df.groupby('region')['revenue'].sum().reset_index()
region_fig = px.pie(region_sales, names='region', values='revenue',
                   title="Revenue Distribution by Region")

# Layout
app.layout = html.Div([
    navbar,
    dbc.Container([
        html.H3("Sales Performance Dashboard", className="mb-4"),

        # Key metrics cards
        dbc.Row([
            dbc.Col([
                dbc.Card([
                    dbc.CardBody([
                        html.H5("Total Revenue", className="card-title"),
                        html.H3(f"${sales_df['revenue'].sum():,.0f}", className="text-success")
                    ])
                ])
            ], width=4),
            dbc.Col([
                dbc.Card([
                    dbc.CardBody([
                        html.H5("Total Units Sold", className="card-title"),
                        html.H3(f"{sales_df['units_sold'].sum():,}", className="text-primary")
                    ])
                ])
            ], width=4),
            dbc.Col([
                dbc.Card([
                    dbc.CardBody([
                        html.H5("Avg Revenue/Unit", className="card-title"),
                        html.H3(f"${(sales_df['revenue'].sum() / sales_df['units_sold'].sum()):.2f}", className="text-info")
                    ])
                ])
            ], width=4)
        ], className="mb-4"),

        # Charts
        dbc.Row([
            dbc.Col([dcc.Graph(figure=time_fig)], width=12)
        ]),
        dbc.Row([
            dbc.Col([dcc.Graph(figure=product_fig)], width=6),
            dbc.Col([dcc.Graph(figure=region_fig)], width=6)
        ])
    ], fluid=True)
])

if __name__ == '__main__':
    port = int(os.getenv('PORT', 8050))
    app.run_server(debug=False, host='0.0.0.0', port=port)
