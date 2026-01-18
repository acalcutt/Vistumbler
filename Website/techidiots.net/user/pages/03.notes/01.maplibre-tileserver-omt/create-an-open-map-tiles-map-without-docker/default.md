---
title: 'Create an OpenMapTiles map without docker'
date: '07-07-2022 09:01'
visible: true
---

The [OpenMapTiles](https://openmaptiles.org/) project has done a lot of great work to take the OpenStreetmap data and create a beautiful vector mbtiles map. While they do keep their project Open Source, I think in the interest of making money, they make their open source contribution a bit obfuscated. Each step is buried in docker images which makes it tough to understand.

To understand what OpenMapTiles was doing under the hood, I set out to de-dockerize it. I have created the following project, wdb-map-tiles, which Is made to run everything right in debian 11 without docker.  
<https://github.com/acalcutt/wdb-map-gen/tree/OpenMapTiles/>

**\*\*UPDATE\*\***
------------------

**Please check the up to date README at <https://github.com/acalcutt/wdb-map-gen/tree/OpenMapTiles/> where the process below has been automated, updated, and simplified. the article below is my first version of this, but it has been improved in the github repository.**

**Setting up a base Server**
----------------------------

OpenMapTiles generation without docker needs the following components

1. PostgreSQL (I used 13)
2. osml10n Postgres extension ( https://github.com/giggls/mapnik-german-l10n.git )
3. gzip Postgres extension ( https://github.com/pramsey/pgsql-gzip.git )
4. GEOS ( https://trac.osgeo.org/geos )
5. proj ( https://www.osgeo.org/projects/proj/ )
6. gdal ( https://github.com/OSGeo/gdal )
7. postgis ( https://postgis.net/install/ )
8. GO ( https://golang.org/dl/ )
9. Leveldb ( https://github.com/google/leveldb )
10. Imposm ( https://github.com/omniscale/imposm3 )
11. openmaptiles-tools ( https://github.com/openmaptiles/openmaptiles-tools )
12. libosmium ( https://github.com/osmcode/libosmium )
13. osmborder ( https://github.com/pnorman/osmborder )
14. node/nvm
 
Setting this up on Debian 11``

1. Python Python-3 with pip 
    1. apt-get install zlib1g-dev libssl-dev libffi-dev curl wget python3 python3-pip
    2. export PATH="/usr/lib/postgresql/13/bin:$PATH"
2. openmaptiles-tools install  
    
    1. apt-get install graphviz sqlite3 aria2 osmctools git
    2. python3 -m pip install git+https://github.com/openmaptiles/openmaptiles-tools
3. Posgresql 13 
    1. sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb\_release -cs)-pgdg main" &gt; /etc/apt/sources.list.d/pgdg.list'
    2. wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
    3. apt-get update
    4. apt-get install postgresql-13 postgresql-server-dev-13
    5. systemctl enable postgresql
4. osml10n Postgres extension 
    1. sudo apt-get install devscripts equivs libicu-dev postgresql-server-dev-all libkakasi2-dev libutf8proc-dev pandoc
    2. git clone https://github.com/giggls/mapnik-german-l10n.git
    3. cd mapnik-german-l10n
    4. make
    5. make install
5. gzip Postgres extension 
    1. sudo apt-get install build-essential zlib1g-dev postgresql-server-dev-all pkg-config fakeroot devscripts
    2. git clone https://github.com/pramsey/pgsql-gzip.git
    3. cd pgsql-gzip
    4. make
    5. make install
6. GEOS  
    
    1. wget http://download.osgeo.org/geos/geos-3.9.0.tar.bz2
    2. tar -xvf geos-3.9.0.tar.bz2
    3. cd geos-3.9.0/
    4. ./configure
    5. make -j
    6. make install
7. Install proj 
    1. apt-get install sqlite3 libsqlite3-dev libtiff-dev libcurl4-openssl-dev pkg-config
    2. wget https://download.osgeo.org/proj/proj-7.1.1.tar.gz
    3. tar -xvf proj-7.1.1.tar.gz
    4. cd proj-7.1.1
    5. ./configure
    6. make
    7. make install
    8. \#Fix so 'proj --version' works. Fixed ( ERROR: could not load library "/usr/lib/postgresql/12/lib/postgis-3.so": libproj.so.19: cannot open shared object file: No such file or directory ) 
        1. ln -s /usr/local/lib/libproj.so.19 /usr/lib/libproj.so.19
        2. ln -s /usr/local/lib/libproj.so.19.1.1 /usr/lib/libproj.so.19.1.1
8. Install gdal 
    1. apt-get install libsqlite3-dev
    2. wget https://github.com/OSGeo/gdal/releases/download/v3.1.3/gdal-3.1.3.tar.gz
    3. tar -xvf gdal-3.1.3.tar.gz
    4. cd gdal-3.1.3
    5. ./configure --with-proj=/usr/local
    6. make
    7. make install
    8. Fix for (ogr2ogr: error while loading shared libraries: libgdal.so.27: cannot open shared object file: No such file or directory) 
        1. ln -s /usr/local/lib/libgdal.so.27.0.3 /usr/lib/libgdal.so.27.0.3
        2. ln -s /usr/local/lib/libgdal.so /usr/lib/libgdal.so
        3. ln -s /usr/local/lib/libgdal.so.27 /usr/lib/libgdal.so.27
9. postgis 
    1. apt-get install libxml2-dev libprotobuf-dev libprotobuf-c-dev protobuf-c-compiler
    2. wget https://download.osgeo.org/postgis/source/postgis-3.1.0.tar.gz
    3. tar -xvf postgis-3.1.0.tar.gz
    4. cd postgis-3.1.0
    5. ./configure
    6. make
    7. make install
10. GO 
    1. wget https://golang.org/dl/go1.15.2.linux-amd64.tar.gz
    2. tar -xvf go1.15.2.linux-amd64.tar.gz
    3. mv go /usr/local
11. Leveldb 
    1. wget https://github.com/google/leveldb/archive/v1.19.tar.gz
    2. tar -xvf v1.19.tar.gz
    3. cd leveldb-1.19/
    4. make
    5. scp out-static/lib\* out-shared/lib\* /usr/local/lib/
    6. cd include/
    7. scp -r leveldb /usr/local/include/
12. Imposm 
    1. sudo apt-get install libgeos-dev libleveldb-dev build-essential
    2. cd \[wdb-map-gen DIR\]/imposm3
    3. export GOPATH=`pwd`
    4. go get github.com/omniscale/imposm3
    5. go install github.com/omniscale/imposm3/cmd/imposm
13. Install libosmium (needed by osmborder) 
    1. apt-get install libbz2-dev libprotozero-dev libboost-tools-dev libboost-thread-dev cmake clang-tidy
    2. cd /opt
    3. git clone https://github.com/osmcode/libosmium.git
    4. cd libosmium
    5. mkdir build
    6. cd build
    7. cmake ..
    8. make
    9. make install
14. Install osmborder 
    1. cd /opt
    2. git clone https://github.com/pnorman/osmborder.git
    3. cd osmborder
    4. mkdir build
    5. cd build
    6. cmake ..
    7. make
    8. make install
15. Node Version Manager 
    1. wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
    2. nvm install v8.15.0
    3. nvm use v8.15.0
16. tile-copy  
    
    1. npm install --unsafe-perm -g tl mapnik@^3.7.2 @mapbox/mbtiles @mapbox/tilelive @mapbox/tilelive-vector @mapbox/tilelive-bridge @mapbox/tilelive-mapnik git+https://github.com/acalcutt/tilelive-tmsource.git
 
Loading data into Postgresql
----------------------------

The process to load the data OpenMapTiles needs looks like the following

1. Create a osm database with the required extensions
2. Load the water shape file and lake centerlines using ogr2ogr
3. Create the border csv file using osmborder tool and load it using pgfutter
4. Load the natural earth shape files.
5. Create a TM2 source with the OpenMapTiles yaml/layer files using generate-imposm3
6. Download a OpenStreetMap PBF using download-osm
7. Load the PBF file using imposm3
8. Load the wikidata using import-wikidata
9. Load the openmaptiles-tools sql functions ( https://github.com/openmaptiles/openmaptiles-tools/tree/master/sql )
10. Generate SQL with generate-sql
11. Load the Generated sql with psql (for single threaded) or import-sql (for multi-threaded)
12. At this point you should be ready to export to mbtiles or serve with postserve/postile directly (provided there are no errors :) )
 
Loading with [wdb-map-gen](https://github.com/acalcutt/wdb-map-gen)

1. git clone https://github.com/acalcutt/wdb-map-gen.git
2. cd wdb-map-gen
3. Import data  
    **All at once**  
     ./load\_all.sh  
    **One step at a time**  ./create\_db.sh  
     ./load\_water.sh  
     ./load\_osmborder.sh  
     ./load\_naturalearth.sh  
     ./load\_planet.sh  
     ./load\_wikidata.sh  
     ./load\_sql.sh
 
Export to vectortiles/mbtiles for TileServer-GL
-----------------------------------------------

The process to export to mbtiles looks like this

1. Create a TM2 source with the OpenMapTiles yaml/layer files using generate-imposm3 (you can use the same one from the import if you want, but I use a slightly cut down version at this step)
2. Use tile-copy to export from postgresql into a mbtiles file.   
    \*note - set $UV\_THREADPOOL\_SIZE environment variable to something like cores \* 1.5 to improve tile-copy performance\*
 
Export with [wdb-map-gen](https://github.com/acalcutt/wdb-map-gen)

1. git clone https://github.com/acalcutt/wdb-map-gen.git
2. cd wdb-map-gen
3. ./export\_mbtiles.sh
 
Serve live from postgresql with postile
---------------------------------------

1. Create a TM2 source with the OpenMapTiles yaml/layer files using generate-imposm3
2. Download the OpenMapTiles style ( <https://github.com/openmaptiles/osm-bright-gl-style/releases> ) and fonts
3. Serve with Postile 
    1. postile --cors --tm2 openmaptiles.tm2source/data.yaml --pghost 127.0.0.1 --pguser \[username\] --pgpassword \[password\] --listen \[ip\] --pgdatabase osm --style style/style.json --fonts fonts/
 
Performance
-----------

I am running this on a 28 core vmware virtual server (AMD Threadripper) with 64GB of memory. The vm disks are on a 2TB nvme volume and the vm using using nvme controllers.

Export took about 3 days  
`[2d 20h 5m 40.9s] 100.0000% 51.39m/51.39m @ 275/s | ✓ 51.39m □ 306.53m | 0.0s left`  
`root@mapgen-debian:/work/wdb-map-gen# ls -l --block-size=G data/tiles.mbtiles`  
`-rw-r--r-- 1 root root 65G Feb 28 08:04 data/tiles.mbtiles<br></br>`

My initial setup of this performed horribly to load the full planet, with estimates ranging from 200-2000+ days initially, which would have been unworkable. After some tweaking I was able to get this down to 16-30 days initially.. From what I have read, the OpenMapTiles project was using a cluster of 30 (4 core) servers to generate the planet in 1 day. I have also read about a 96 core AC2 instance being able to do this in 1 day. If I had 100+ cores I think I would get similar performance.

#### **Postgresql**

For my Postgresql settings I did the following

1. I started with pgtune (https://pgtune.leopard.in.ua/#/)
2. Use the openmaptiles-tools 'test-perf' tool to check your configuration. when i initially ran this, it told me "disable JIT in PG 11+ for complex queries", which seems to be the thing that made this finally perform well
3. Lots of manual tweaking. Initially I was using way to much memory and the constant swapping was hurting postgresql performance. Lowering the memory use so the system was not swapping helped a lot.
 
My settings, as shown by test-perf, are currently the following

`* version() = PostgreSQL 13.1 (Debian 13.1-1.pgdg110+2) on x86_64-pc-linux-gnu, compiled by gcc (Debian 10.2.1-3) 10.2`  
`.1 20201224, 64-bit`  
`* postgis_full_version() = POSTGIS="3.1.0 5e2af69" [EXTENSION] PGSQL="130" GEOS="3.9.0-CAPI-1.16.2" PROJ="7.1.1" LIBXML="2.9.10" LI`  
`BPROTOBUF="1.3.3" WAGYU="0.5.0 (Internal)"`  
`* jit = off`  
`* shared_buffers = 16GB`  
`* work_mem = 8MB`  
`* maintenance_work_mem = 2GB`  
`* effective_cache_size = 48GB`  
`* effective_io_concurrency = 200`  
`* max_connections = 100`  
`* max_worker_processes = 20`  
`* max_parallel_workers = 20`  
`* max_parallel_workers_per_gather = 10`  
`* wal_buffers = 16MB`  
`* min_wal_size = 4GB`  
`* max_wal_size = 16GB`  
`* random_page_cost = 1.1`  
`* default_statistics_target = 500`  
`* checkpoint_completion_target = 0.9`

\*note\* I am not very familiar with postgreql performance, so take my suggestions lightly :) . I posted my settings as an example because there isn't a lot out there for improving postgresql performance with postgis/geospatial functions

**Node**

Don't forget to set the UV\_THREADPOOL\_SIZE environment variable. From what I have read this defaults to 4 threads, which limits node when you have more cores to use. I am settings this to at least (cpu cores \* 1.5). If you are using my export\_mbtiles.sh this will get set to what is in config/env.config

See: [Parallelizing openmaptile vector map tile generation - 16x speedup with two variables](https://bravetheheat.medium.com/parallelizing-openmaptile-vector-map-tile-generation-16x-speedup-with-two-variables-120afa11d839)

<div style="border: 1px solid #ddd; margin-bottom: 20px; padding: 10px; background-color: #f9f9f9;">
	<div style="font-weight: bold; text-align: center;">Advertisement</div>
	<div class="adsense-content" style="margin-top: 5px; text-align: center;">
        [adsense id="unique-id"][/adsense]
    </div>
</div>'