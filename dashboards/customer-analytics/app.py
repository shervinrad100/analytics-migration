import dash
from dash import dcc, html
import plotly.express as px
import pandas as pd
import dash_bootstrap_components as dbc
import os
from google.cloud import storage

# Initialize Dash app
app = dash.Dash(__name__, external_stylesheets=[dbc.themes.BOOTSTRAP])
app.title = "Customer Analytics"
server = app.server

def load_data_from_gcs():
    """Load customer data from Google Cloud Storage"""
    bucket_name = os.getenv('DATA_BUCKET')
    if not bucket_name:
        raise Exception("DATA_BUCKET environment variable not set")

    # Load from GCS
    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob('dashboards/customer_data.csv')

    # Download to temp file
    blob.download_to_filename('/tmp/customer_data.csv')
    return pd.read_csv('/tmp/customer_data.csv')

# Load customer data
customer_df = load_data_from_gcs()
customer_df['signup_date'] = pd.to_datetime(customer_df['signup_date'])

# Create navbar
navbar = dbc.NavbarSimple(
    children=[
        dbc.NavItem(dbc.NavLink("Customer Analytics", href="/", active=True)),
    ],
    brand="Analytics Platform - Customers",
    brand_href="/",
    color="primary",
    dark=True,
    className="mb-4"
)

# Age distribution
age_fig = px.histogram(customer_df, x='age', nbins=20,
                      title="Customer Age Distribution")

# Spending by location
location_spending = customer_df.groupby('location')['total_spent'].sum().reset_index()
location_fig = px.bar(location_spending, x='location', y='total_spent',
                     title="Total Spending by Location")

# Gender split
gender_fig = px.pie(customer_df, names='gender',
                   title="Customer Gender Distribution")

# Layout
app.layout = html.Div([
    navbar,
    dbc.Container([
        html.H3("Customer Analytics Dashboard", className="mb-4"),

        # Key metrics cards
        dbc.Row([
            dbc.Col([
                dbc.Card([
                    dbc.CardBody([
                        html.H5("Total Customers", className="card-title"),
                        html.H3(f"{len(customer_df):,}", className="text-primary")
                    ])
                ])
            ], width=4),
            dbc.Col([
                dbc.Card([
                    dbc.CardBody([
                        html.H5("Average Spending", className="card-title"),
                        html.H3(f"${customer_df['total_spent'].mean():.2f}", className="text-success")
                    ])
                ])
            ], width=4),
            dbc.Col([
                dbc.Card([
                    dbc.CardBody([
                        html.H5("Average Age", className="card-title"),
                        html.H3(f"{customer_df['age'].mean():.1f} years", className="text-info")
                    ])
                ])
            ], width=4)
        ], className="mb-4"),

        # Charts
        dbc.Row([
            dbc.Col([dcc.Graph(figure=age_fig)], width=6),
            dbc.Col([dcc.Graph(figure=gender_fig)], width=6)
        ]),
        dbc.Row([
            dbc.Col([dcc.Graph(figure=location_fig)], width=12)
        ])
    ], fluid=True)
])

if __name__ == '__main__':
    port = int(os.getenv('PORT', 8050))
    app.run_server(debug=False, host='0.0.0.0', port=port)
