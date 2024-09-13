import pandas as pd
import numpy as np
import plotly.graph_objects as go
import plotly.io as pio
from argparse import ArgumentParser
from plotly.subplots import make_subplots

parser = ArgumentParser()
parser.add_argument("workload", type=str)
parser.add_argument("region", type=str)
args = parser.parse_args()

# Load the CSV data
data = pd.read_csv(f'{args.workload}-{args.region}.csv')

# Normalize the 'Conclusion' column to just "Failure" and "Success"
data['Conclusion'] = data['Conclusion'].apply(lambda x: 'Success' if '✓' in x else 'Failure')

# Convert the 'Date' column to datetime format and extract the date
data['Date'] = pd.to_datetime(data['Date']).dt.date

# Create a 'Success' column with binary values
data['Success'] = data['Conclusion'].apply(lambda x: 1 if x == 'Success' else 0)

# Group data by 'Date' to get total runs and number of successes per day
grouped_data = data.groupby('Date').agg(
    total_runs=('Conclusion', 'count'),
    total_successes=('Success', 'sum')
).reset_index()

# Calculate success rate
grouped_data['success_rate'] = grouped_data['total_successes'] / grouped_data['total_runs']

# Create a figure with secondary y-axis
fig = make_subplots(specs=[[{"secondary_y": True}]])

# Add area fill trace for success rate (behind the bars)
fig.add_trace(
    go.Scatter(
        x=grouped_data['Date'],
        y=grouped_data['success_rate'],
        name='Success Rate Area',
        mode='lines',
        line=dict(color='rgba(0,0,0,0)'),  # Transparent line
        fill='tozeroy',
        fillcolor='rgba(0, 100, 80, 0.2)',  # Faint shading
        hoverinfo='skip',  # Hide hover info for the area
        showlegend=False,
        yaxis='y2',
    ),
    secondary_y=True,
)

# Loop through each pair of consecutive points to create line segments
for i in range(len(grouped_data) - 1):
    x_vals = [grouped_data['Date'].iloc[i], grouped_data['Date'].iloc[i+1]]
    y_vals = [grouped_data['success_rate'].iloc[i], grouped_data['success_rate'].iloc[i+1]]

    # Determine the color for the line segment based on the success rates
    if grouped_data['success_rate'].iloc[i] == 1 and grouped_data['success_rate'].iloc[i+1] == 1:
        color = 'green'
    else:
        color = 'red'

    # Add the line segment to the figure
    fig.add_trace(
        go.Scatter(
            x=x_vals,
            y=y_vals,
            mode='lines',
            line=dict(color=color),
            showlegend=False,
            yaxis='y2',
        ),
        secondary_y=True,
    )

# Add markers for the data points
fig.add_trace(
    go.Scatter(
        x=grouped_data['Date'],
        y=grouped_data['success_rate'],
        mode='markers',
        marker=dict(
            color=['green' if sr == 1 else 'red' for sr in grouped_data['success_rate']],
            size=8
        ),
        name='Success Rate',
        yaxis='y2',
    ),
    secondary_y=True,
)

# Add bar trace for total runs (on top of the line traces)
fig.add_trace(
    go.Bar(
        x=grouped_data['Date'],
        y=grouped_data['total_runs'],
        name='Total Runs',
        marker_color='gray',
        opacity=0.6  # Semi-transparent bars
    ),
    secondary_y=False,
)

# Update layout
fig.update_layout(
    title_text=f'{args.workload} - {args.region}',
    xaxis_title='Date',
    yaxis_title='Total Runs',
    yaxis2_title='Success Rate',
    yaxis2=dict(
        overlaying='y',
        side='right',
        range=[0, 1.05]
    ),
    legend=dict(x=0.01, y=0.99, bgcolor='rgba(255,255,255,0)'),
)

# Save the figure as an HTML file
pio.write_html(
    fig,
    file=f'{args.workload}-{args.region}.html',
    auto_open=True,
    full_html=False,
    include_plotlyjs=False,
    default_width="600",
    default_height="400"
)