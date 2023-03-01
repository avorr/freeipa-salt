FROM alt:p9

WORKDIR /opt

RUN apt-get update && apt-get install -y python3 python3-module-pip python3-module-setuptools gcc

RUN pip3 install python-freeipa salt==3004

COPY scripts/unenrol.py .

ENTRYPOINT ["python3", "unenrol.py"]