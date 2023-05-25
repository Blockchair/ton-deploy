FROM ubuntu:20.04 as ton_builder
RUN apt-get update --fix-missing && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential cmake clang-6.0 \
 clang++-6.0   libtool openssl libssl-dev zlib1g-dev gperf wget git autoconf libpq-dev libmicrohttpd-dev pkg-config cmake-data ninja-build

ENV CC clang-6.0
ENV CXX clang++-6.0

WORKDIR /

RUN git clone https://github.com/jgarzik/univalue.git
WORKDIR /univalue

RUN ./autogen.sh && \
    ./configure  &&  \
    make && make install

WORKDIR /

RUN wget https://github.com/jtv/libpqxx/archive/refs/tags/6.4.8.tar.gz --output-document=libpqxx.tar.gz
RUN tar -xvzf libpqxx.tar.gz

WORKDIR /libpqxx-6.4.8
RUN chmod +x configure && \
        ./configure CXX='clang++' --disable-documentation CXXFLAGS='-std=c++14' && \
        make && make install

WORKDIR /

RUN git clone --recursive https://github.com/ton-blockchain/ton.git
WORKDIR /ton

RUN git submodule add https://github.com/Blockchair/ton-indexer.git 
RUN git submodule add https://github.com/Blockchair/ton-api.git

WORKDIR /ton/ton-medium-client

RUN cp -r medium-client /ton && cp medium-client/FindPQXX.cmake /ton/CMake/

WORKDIR /ton 
RUN sed -i "s/add_subdirectory(lite-client)/add_subdirectory(lite-client)\nadd_subdirectory(medium-client)\nadd_subdirectory(blockchain-api)/" CMakeLists.txt

RUN mkdir build && \
	cd build && \
	cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DPORTABLE=1 -DTON_ARCH= -DCMAKE_CXX_FLAGS="-mavx2" -DCMAKE_C_COMPILER:FILEPATH=/usr/bin/clang -DCMAKE_CXX_COMPILER:FILEPATH=/usr/bin/clang++ .. && \
	ninja storage-daemon storage-daemon-cli tonlibjson fift func validator-engine validator-engine-console generate-random-id dht-server lite-client blockchain-api medium-client

WORKDIR /