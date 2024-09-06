import pandas as pd
import plotly.express as px
import plotly.io as pio
from argparse import ArgumentParser

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

# Group the data by 'Date' and 'Conclusion'
grouped_data = data.groupby(['Date', 'Conclusion']).size().unstack(fill_value=0)

# Normalize the data to get the ratio (percentage) for each conclusion per day
ratio_data = grouped_data.div(grouped_data.sum(axis=1), axis=0).reset_index()

# Identify existing columns (Success, Failure) in the ratio_data DataFrame
existing_columns = [col for col in ['Success', 'Failure'] if col in ratio_data.columns]

# Melt the DataFrame only with the existing columns
melted_data = ratio_data.melt(id_vars='Date', value_vars=existing_columns,
                              var_name='Conclusion', value_name='Ratio')

# Plot the data as a stacked bar chart
fig = px.bar(melted_data, x='Date', y='Ratio', color='Conclusion',
             title=f'{args.workload} - {args.region}',
             labels={'Ratio':'Success Rate', 'Date':'Date'},
             color_discrete_map={'Success': 'green', 'Failure': 'red'},
             barmode='stack')

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