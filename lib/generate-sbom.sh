#!/bin/bash
set -e

# Create a directory to hold all the generated SBOMs
mkdir -p sbom-reports

# Find every directory containing a pom.xml
find . -name "pom.xml" | while read pom_file; do
    # Get the directory of the pom.xml
    project_dir=$(dirname "$pom_file")
    project_name=$(basename "$project_dir")

    echo "================================================"
    echo "Processing: $project_name"
    echo "================================================"

    cd "$project_dir"

    # 1. Build the project to ensure target/ is up to date
    echo "Building $project_name..."
    #mvn clean package -DskipTests -q

    # 2. Generate the SBOM using the CycloneDX Maven Plugin
    # This reads the resolved dependency graph AND the built artifacts
    echo "Generating SBOM for $project_name..."
    mvn org.cyclonedx:cyclonedx-maven-plugin:makeBom -q

    # 3. Copy the generated SBOM to our central reports directory
    if [ -f "target/bom.json" ]; then
        cp target/bom.json "../../sbom-reports/${project_name}-bom.json"
        echo "✅ Successfully generated SBOM for $project_name"
    else
        echo "❌ Failed to generate SBOM for $project_name"
    fi

    # Return to the root directory
    cd - > /dev/null
done

echo "================================================"
echo "All SBOMs generated and saved in ./sbom-reports/"
echo "================================================"
 
