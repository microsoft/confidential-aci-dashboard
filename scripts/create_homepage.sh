#!/bin/bash

scripts_dir=$(dirname "$(readlink -f "$0")")
template_file="$scripts_dir/templates/graphs.html"
output_file="index.html"

cp "$template_file" "$output_file"

# Initialize empty arrays to hold workloads and regions
declare -A workloads
declare -A regions

for file in *.html; do
    if [ "$file" != "index.html" ]; then
        # Extract workload and region from the filename (assuming format is workload_region.html)
        filename=$(basename -- "$file")
        filename="${filename%.html}"

        # Split filename based on the first hyphen
        workload="${filename%-*}"
        region="${filename##*-}"

        # Add the graph to the template
        awk -v insert="$(cat $file)" -v workload="$workload" -v region="$region" '
            /<div id="graphs"/ { print; inside_graphs_div=1; next }
            inside_graphs_div && /<\/div>/ {
                print "<div data-workload=\"" workload "\" data-region=\"" region "\" class=\"graph\">" insert "</div>"
                inside_graphs_div=0
            }
            { print }
        ' "$output_file" > "$output_file.tmp" && mv "$output_file.tmp" "$output_file"

        # Store workloads and regions
        workloads["$workload"]=1
        regions["$region"]=1
    fi
done

# Prepare button HTML for unique workloads
workload_buttons=""
for workload in "${!workloads[@]}"; do
    workload_buttons+="<button class=\"toggle-button\" onclick=\"toggleButton(this, 'workload', '$workload')\">$workload</button>\n"
done

# Prepare button HTML for unique regions
region_buttons=""
for region in "${!regions[@]}"; do
    region_buttons+="<button class=\"toggle-button\" onclick=\"toggleButton(this, 'region', '$region')\">$region</button>\n"
done

# Append workload buttons, and region buttons to the template file
awk -v workload_buttons="$workload_buttons" -v region_buttons="$region_buttons" '
    /<div id="workload-filters"/ { print; inside_filters_div=1; next }
    inside_filters_div && /<\/div>/ { print workload_buttons; inside_filters_div=0 }
    /<div id="region-filters"/ { print; inside_region_div=1; next }
    inside_region_div && /<\/div>/ { print region_buttons; inside_region_div=0 }
    { print }
' "$output_file" > "$output_file.tmp" && mv "$output_file.tmp" "$output_file"
