# pull official base image
FROM python:3.8.1-alpine

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# set work directory
WORKDIR /application
COPY . /application

RUN useradd -m -r user_fastapi && \
    chown user_fastapi /application

RUN python3 -m pip install --no-cache-dir --upgrade pip==23.3 && \
    python3 -m pip install --no-cache-dir -r requirements.txt --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org

EXPOSE 8080
USER user_fastapi

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3\
    CMD curl -f http://localhost/ || exit 1

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]