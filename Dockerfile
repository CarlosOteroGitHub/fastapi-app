# pull official base image
FROM python:3.8.1-alpine

# install dependencies for building Python packages
RUN apk update && apk add --no-cache build-base libffi-dev

# install curl for healthcheck
RUN apk add --no-cache curl

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# set work directory
WORKDIR /application
COPY . /application

# create a non-root user and give permissions
RUN addgroup -S user_fastapi && adduser -S -G user_fastapi user_fastapi && \
    chown -R user_fastapi:user_fastapi /application

# install python dependencies
RUN python3 -m pip install --no-cache-dir --upgrade pip==23.3 && \
    python3 -m pip install --no-cache-dir -r requirements.txt --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org

# switch to the non-root user
USER user_fastapi

# expose the port the app runs on
EXPOSE 8000

# healthcheck
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# start the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
