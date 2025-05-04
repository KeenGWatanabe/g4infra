 # (1)
FROM python:alpine

 # Create non-root user and set permissions (2)
 RUN useradd -m appuser && \
     mkdir -p /app && \
     chown appuser:appuser /app
 WORKDIR /app
 # (3)
 USER appuser  
 
 # Use virtual environment (4)
 RUN python -m venv /app/venv
 ENV PATH="/app/venv/bin:$PATH"
 
 # Install dependencies (5)
 COPY --chown=appuser:appuser requirements.txt .
 RUN pip install --no-cache-dir -r requirements.txt
 
 # Copy app code (6)
 COPY --chown=appuser:appuser . .
 # (7)
 EXPOSE 8080  
 
 # Run the app (8)
 CMD ["python", "app.py"]