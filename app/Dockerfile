FROM python:3.10.0-alpine3.14

ARG CI_COMMIT_SHORT_SHA
ENV CI_COMMIT_SHORT_SHA ${CI_COMMIT_SHORT_SHA}
ARG CI_PIPELINE_ID
ENV CI_PIPELINE_ID ${CI_PIPELINE_ID}
ARG CI_COMMIT_TAG
ENV CI_COMMIT_TAG ${CI_COMMIT_TAG}

COPY ./requirements.txt ./requirements.txt

RUN pip install --no-cache-dir -r requirements.txt

RUN addgroup --gid 10001 app \
  && adduser \
    --uid 10001 \
    --home /home/app \
    --shell /bin/ash \
    --ingroup app \
    --disabled-password \
    app

WORKDIR /home/app

USER app

COPY ./ /home/app

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/uvicorn"]
CMD ["main:app", "--reload", "--host=0.0.0.0", "--port=8080"]
