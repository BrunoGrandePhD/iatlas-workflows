FROM tailordev/pandas

RUN pip3 install --upgrade pip
RUN pip3 install argparse

COPY bin/* /usr/local/bin/
RUN chmod a+x /usr/local/bin/*
