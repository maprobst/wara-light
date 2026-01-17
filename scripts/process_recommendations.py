#!/usr/bin/env python3
"""
Script to process recommendations.yaml files from Azure Proactive Resiliency Library v2.
Extracts all recommendation entries and writes them to a CSV file.
"""

import os
import sys
import csv
import glob
from datetime import datetime
from pathlib import Path

import yaml


def find_recommendation_files(base_dir: str) -> list[str]:
    """Find all recommendations.yaml files in the given directory."""
    pattern = os.path.join(base_dir, "**", "recommendations.yaml")
    files = glob.glob(pattern, recursive=True)
    return sorted(files)


def parse_yaml_file(file_path: str) -> list[dict]:
    """Parse a YAML file and return list of recommendation entries."""
    recommendations = []

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = yaml.safe_load(f)

        if content is None:
            return recommendations

        # Handle both list format and dict with list
        if isinstance(content, list):
            recommendations = content
        elif isinstance(content, dict):
            # Some files might have recommendations under a key
            for key, value in content.items():
                if isinstance(value, list):
                    recommendations.extend(value)

    except yaml.YAMLError as e:
        print(f"Error parsing {file_path}: {e}", file=sys.stderr)
    except Exception as e:
        print(f"Error reading {file_path}: {e}", file=sys.stderr)

    return recommendations


def get_all_fieldnames(all_recommendations: list[dict]) -> list[str]:
    """Extract all unique field names from recommendations, with 'description' first."""
    fieldnames = set()
    for rec in all_recommendations:
        if isinstance(rec, dict):
            fieldnames.update(rec.keys())

    # Ensure 'description' is first if present
    fieldnames_list = sorted(fieldnames)
    if 'description' in fieldnames_list:
        fieldnames_list.remove('description')
        fieldnames_list.insert(0, 'description')

    return fieldnames_list


def flatten_value(value) -> str:
    """Flatten complex values to string for CSV output."""
    if value is None:
        return ""
    if isinstance(value, (list, dict)):
        return str(value)
    return str(value)


def write_csv(recommendations: list[dict], output_path: str, fieldnames: list[str]) -> None:
    """Write recommendations to CSV file."""
    with open(output_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, extrasaction='ignore')
        writer.writeheader()

        for rec in recommendations:
            if isinstance(rec, dict):
                # Flatten all values
                flattened = {k: flatten_value(v) for k, v in rec.items()}
                writer.writerow(flattened)


def main():
    if len(sys.argv) < 2:
        print("Usage: python process_recommendations.py <directory>", file=sys.stderr)
        sys.exit(1)

    base_dir = sys.argv[1]

    if not os.path.isdir(base_dir):
        print(f"Error: {base_dir} is not a valid directory", file=sys.stderr)
        sys.exit(1)

    print(f"Searching for recommendations.yaml files in: {base_dir}")

    # Find all recommendation files
    yaml_files = find_recommendation_files(base_dir)
    print(f"Found {len(yaml_files)} recommendations.yaml files")

    if not yaml_files:
        print("No recommendations.yaml files found!")
        sys.exit(0)

    # Parse all files
    all_recommendations = []
    for yaml_file in yaml_files:
        print(f"Processing: {yaml_file}")
        recommendations = parse_yaml_file(yaml_file)

        # Add source file info to each recommendation
        relative_path = os.path.relpath(yaml_file, base_dir)
        for rec in recommendations:
            if isinstance(rec, dict):
                rec['_source_file'] = relative_path

        all_recommendations.extend(recommendations)

    print(f"Total recommendations found: {len(all_recommendations)}")

    if not all_recommendations:
        print("No recommendations extracted!")
        sys.exit(0)

    # Generate output filename with current date and time
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    output_filename = f"recommendations_{timestamp}.csv"

    # Determine output path (results directory in current working directory)
    script_dir = Path(__file__).parent.parent
    results_dir = script_dir / "results"
    results_dir.mkdir(exist_ok=True)

    output_path = results_dir / output_filename

    # Get all field names and write CSV
    fieldnames = get_all_fieldnames(all_recommendations)
    write_csv(all_recommendations, str(output_path), fieldnames)

    print(f"CSV file written to: {output_path}")
    print(f"Total entries written: {len(all_recommendations)}")

    # Output the filename for use in GitHub Actions
    print(f"::set-output name=csv_file::{output_filename}")

    return str(output_path)


if __name__ == "__main__":
    main()
