FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy the requirements file
COPY requirements.txt .

# Install dbt and any other dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the dbt project files into the container
COPY flips/dbt_project.yml ./dbt_project.yml
COPY flips/profiles.yml /root/.dbt/profiles.yml
COPY flips/models ./models
COPY flips/analyses ./analyses
COPY flips/tests ./tests
COPY flips/seeds ./seeds
COPY flips/macros ./macros
COPY flips/snapshots ./snapshots


# Create the .dbt directory
# RUN mkdir -p /root/.dbt

RUN mkdir -p /app/duck_db_files

# Copy the dbt profiles.yml file into the container
# COPY flips/profiles.yml /root/.dbt/profiles.yml

# COPY dbt_project.yml /app/flips/dbt_project.yml

# Copy the dbt_project.yml file into the container
# COPY flips/dbt_project.yml /app/flips/dbt_project.yml
# COPY flips/profiles.yml /root/.dbt/profiles.yml

# Set the entrypoint for the container
ENTRYPOINT ["dbt"]

# Default command to run when the container starts
CMD ["run"]