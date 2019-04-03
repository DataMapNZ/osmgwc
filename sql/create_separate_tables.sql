drop table if exists country;
create table country(
  id serial not null primary key,
  osm_id integer,
  name text,
  uppername text,
  geom geometry(multipolygon, 2193)
);
create index gix_country on country using gist(geom);
delete from country;
insert into country(osm_id, name, uppername, geom) 
    SELECT planet_osm_polygon.osm_id,
      planet_osm_polygon.name as name,
      upper(planet_osm_polygon.name) AS uppername,
      st_multi(planet_osm_polygon.way)::geometry(MultiPolygon, 2193) as way
    FROM planet_osm_polygon
    WHERE planet_osm_polygon.admin_level = '2'::text AND planet_osm_polygon.boundary = 'administrative'::text;

drop table if exists amenity;
create table amenity(
	id serial not null primary key,
	osm_id integer,
	geom geometry(multipolygon, 2193)
);
create index gix_amenity on amenity using gist(geom);
delete from amenity;
insert into amenity(osm_id, geom) 
	SELECT planet_osm_polygon.osm_id,
    st_multi(planet_osm_polygon.way)::geometry(MultiPolygon, 2193) as way
   FROM planet_osm_polygon
  WHERE planet_osm_polygon.amenity IS NOT NULL AND (planet_osm_polygon.amenity = ANY (ARRAY['college'::text, 'community_centre'::text, 'courthouse'::text, 'doctors'::text, 'embassy'::text, 'grave_yard'::text, 'hospital'::text, 'library'::text, 'marketplace'::text, 'prison'::text, 'public_building'::text, 'school'::text, 'simming_pool'::text, 'theatre'::text, 'townhall'::text, 'university'::text]));
--delete from amenity where not st_intersects(st_centroid(geom), (ST_CollectionHomogenize(ST_Collect(ARRAY(select geom from country)))));

drop table if exists region;
create table region(
	id serial not null primary key,
	osm_id integer,
	name text,
	uppername text,
	geom geometry(multipolygon, 2193)
);
create index gix_region on region using gist(geom);
delete from region;
insert into region(osm_id, name, uppername, geom) 
	SELECT planet_osm_polygon.osm_id,
    planet_osm_polygon.name as name,
    upper(planet_osm_polygon.name) AS uppername,
    st_multi(planet_osm_polygon.way)::geometry(MultiPolygon, 2193) as way
  FROM planet_osm_polygon
  WHERE planet_osm_polygon.admin_level = '4'::text AND planet_osm_polygon.boundary = 'administrative'::text;

drop table if exists buildings;
create table buildings(
  id serial not null primary key,
  osm_id integer,
  name text,
  housename text,
  housenumber text,
  geom geometry(multipolygon, 2193)
);
create index gix_buildings on buildings using gist(geom);
delete from buildings;
insert into buildings(osm_id, name, housename, housenumber, geom) 
    SELECT planet_osm_polygon.osm_id, 
      planet_osm_polygon.name,  
      planet_osm_polygon."addr:housename",
       planet_osm_polygon."addr:housenumber",
      st_multi(planet_osm_polygon.way)::geometry(MultiPolygon, 2193) as way
    FROM planet_osm_polygon
    WHERE planet_osm_polygon.building IS NOT NULL AND st_area(planet_osm_polygon.way) < 100000::double precision;
--delete from buildings where not st_intersects(st_centroid(geom), (ST_CollectionHomogenize(ST_Collect(ARRAY(select geom from country)))));

drop table if exists district;
create table district(
  id serial not null primary key,
  osm_id integer,
  name text,
  uppername text,
  geom geometry(multipolygon, 2193)
);
create index gix_district on district using gist(geom);
delete from district;
insert into district(osm_id, name, uppername, geom) 
  SELECT planet_osm_polygon.osm_id, 
    planet_osm_polygon.name, 
    upper(planet_osm_polygon.name) AS uppername,
    st_multi(planet_osm_polygon.way)::geometry(MultiPolygon, 2193) as way
  FROM planet_osm_polygon
  WHERE planet_osm_polygon.admin_level = '6'::text AND planet_osm_polygon.boundary = 'administrative'::text;
delete from district where not st_intersects(st_centroid(geom), (ST_CollectionHomogenize(ST_Collect(ARRAY(select geom from country)))));

drop table if exists forestpark;
create table forestpark(
  id serial not null primary key,
  osm_id integer,
  name text,
  boundary text,
  geom geometry(multipolygon, 2193)
);
create index gix_forestpark on forestpark using gist(geom);
delete from forestpark;
insert into forestpark(osm_id, name, boundary, geom) 
  SELECT planet_osm_polygon.osm_id, 
    planet_osm_polygon.name, 
    planet_osm_polygon.boundary, 
    st_multi(planet_osm_polygon.way)::geometry(MultiPolygon, 2193) as way
  FROM planet_osm_polygon
  WHERE (planet_osm_polygon.landuse = ANY (ARRAY['forest'::text, 'orchard'::text, 'park'::text, 'plant_nursery'::text, 'grass'::text, 'greenfield'::text, 'meadow'::text, 'recreation_ground'::text, 'village_green'::text, 'vineyard'::text])) 
  OR (planet_osm_polygon.leisure = ANY (ARRAY['nature_reserve'::text, 'park'::text, 'dog_park'::text, 'garden'::text, 'golf_course'::text, 'horse_riding'::text, 'recreation_ground'::text, 'stadium'::text])) 
  OR (planet_osm_polygon.boundary = ANY (ARRAY['national_park'::text, 'protected_area'::text]));
delete from forestpark where not st_intersects(st_centroid(geom), (ST_CollectionHomogenize(ST_Collect(ARRAY(select geom from country)))));

drop table if exists lakes;
create table lakes(
  id serial not null primary key,
  osm_id integer,
  name text,
  way_area real,
  geom geometry(multipolygon, 2193)
);
create index gix_lakes on lakes using gist(geom);
delete from lakes;
insert into lakes(osm_id, name, way_area, geom) 
  SELECT planet_osm_polygon.osm_id, 
    planet_osm_polygon.name,  
    planet_osm_polygon.way_area,
    st_multi(planet_osm_polygon.way)::geometry(MultiPolygon, 2193) as way
  FROM planet_osm_polygon
  WHERE planet_osm_polygon."natural" = 'water'::text AND (planet_osm_polygon.water IS NULL OR planet_osm_polygon.water IS NOT NULL AND planet_osm_polygon.water <> 'river'::text);
delete from lakes where not st_intersects(st_centroid(geom), (ST_CollectionHomogenize(ST_Collect(ARRAY(select geom from country)))));

drop table if exists minor_roads;
create table minor_roads(
  id serial not null primary key,
  osm_id integer,
  name text,
  geom geometry(multilinestring, 2193)
);
create index gix_minor_roads on minor_roads using gist(geom);
delete from minor_roads;
insert into minor_roads(osm_id, name, geom) 
  SELECT planet_osm_line.osm_id, 
    planet_osm_line.name,  
    st_multi(planet_osm_line.way)::geometry(MultiLineString, 2193) as way
  FROM planet_osm_line
  WHERE planet_osm_line.highway IS NOT NULL AND (planet_osm_line.highway <> ALL (ARRAY['motorway'::text, 'motorway_link'::text, 'trunk'::text, 'primary'::text, 'trunk_link'::text, 'primary_link'::text, 'secondary'::text, 'secondary_link'::text, 'road'::text, 'tertiary'::text, 'tertiary_link'::text, 'steps'::text, 'footway'::text, 'path'::text, 'pedestrian'::text, 'walkway'::text, 'service'::text, 'track'::text])) AND planet_osm_line.railway IS NULL OR planet_osm_line.railway = 'no'::text;
--delete from minor_roads where not st_intersects(st_centroid(geom), (ST_CollectionHomogenize(ST_Collect(ARRAY(select geom from country)))));

drop table if exists motorway;
create table motorway(
  id serial not null primary key,
  osm_id integer,
  name text,
  geom geometry(multilinestring, 2193)
);
create index gix_motorway on motorway using gist(geom);
delete from motorway;
insert into motorway(osm_id, name, geom) 
  SELECT planet_osm_line.osm_id, 
 	  planet_osm_line.name,  
    st_multi(planet_osm_line.way)::geometry(MultiLineString, 2193) as way
  FROM planet_osm_line
  WHERE planet_osm_line.highway = 'motorway'::text;
delete from motorway where not st_intersects(st_centroid(geom), (ST_CollectionHomogenize(ST_Collect(ARRAY(select geom from country)))));

drop table if exists pedestrian;
create table pedestrian(
  id serial not null primary key,
  osm_id integer,
  name text,
  geom geometry(multilinestring, 2193)
);
create index gix_pedestrian on pedestrian using gist(geom);
delete from pedestrian;
insert into pedestrian(osm_id, name, geom) 
  SELECT planet_osm_line.osm_id, 
   	planet_osm_line.name, 
    st_multi(planet_osm_line.way)::geometry(MultiLineString, 2193) as way
  FROM planet_osm_line
  WHERE planet_osm_line.highway = ANY (ARRAY['steps'::text, 'footway'::text, 'path'::text, 'pedestrian'::text, 'walkway'::text, 'service'::text, 'track'::text]);
--delete from pedestrian where not st_intersects(st_centroid(geom), (ST_CollectionHomogenize(ST_Collect(ARRAY(select geom from country)))));

drop table if exists rails;
create table rails(
  id serial not null primary key,
  osm_id integer,
  name text,
  geom geometry(multilinestring, 2193)
);
create index gix_rails on rails using gist(geom);
delete from rails;
insert into rails(osm_id, name, geom) 
  SELECT planet_osm_line.osm_id, 
    planet_osm_line.name,  
    st_multi(planet_osm_line.way)::geometry(MultiLineString, 2193) as way
  FROM planet_osm_line
  WHERE planet_osm_line.railway IS NOT NULL AND (planet_osm_line.railway = ANY (ARRAY['light rail'::text, 'rail'::text, 'rail;construction'::text, 'tram'::text, 'yes'::text, 'traverser'::text])) OR planet_osm_line.railway ~~ '%rail%'::text;
--delete from rails where not st_intersects(st_centroid(geom), (ST_CollectionHomogenize(ST_Collect(ARRAY(select geom from country)))));

drop table if exists roads;
create table roads(
  id serial not null primary key,
  osm_id integer,
  name text,
  geom geometry(multilinestring, 2193)
);
create index gix_roads on roads using gist(geom);
delete from roads;
insert into roads(osm_id, name, geom) 
 SELECT planet_osm_line.osm_id, 
    planet_osm_line.name,  
    st_multi(planet_osm_line.way)::geometry(MultiLineString, 2193) as way
   FROM planet_osm_line
  WHERE planet_osm_line.highway = ANY (ARRAY['trunk_link'::text, 'primary_link'::text, 'secondary'::text, 'secondary_link'::text, 'road'::text, 'tertiary'::text, 'tertiary_link'::text]);
--delete from roads where not st_intersects(st_centroid(geom), (ST_CollectionHomogenize(ST_Collect(ARRAY(select geom from country)))));

drop table if exists settlements;
create table settlements(
  id serial not null primary key,
  osm_id bigint,
  name text,
  uppername text,
  place text,
  population integer,
  geom geometry(Point, 2193)
);
create index gix_settlements on settlements using gist(geom);
delete from settlements;
insert into settlements(osm_id, name, uppername, place, population, geom) 
  SELECT planet_osm_point.osm_id, 
    planet_osm_point.name, 
    upper(planet_osm_point.name) AS uppername,
    planet_osm_point.place AS place,
    coalesce(planet_osm_point.population::integer, 0) AS population,
    planet_osm_point.way as way
  FROM planet_osm_point
  WHERE planet_osm_point.place = ANY (ARRAY['city'::text, 'town'::text, 'hamlet'::text, 'village'::text, 'suburb'::text]);
--delete from settlements where not st_intersects(st_centroid(geom), (ST_CollectionHomogenize(ST_Collect(ARRAY(select geom from country)))));

drop table if exists trunk_primary;
create table trunk_primary(
  id serial not null primary key,
  osm_id integer,
  name text,
  geom geometry(multilinestring, 2193)
);
create index gix_trunk_primary on trunk_primary using gist(geom);
delete from trunk_primary;
insert into trunk_primary(osm_id, name, geom) 
  SELECT planet_osm_line.osm_id, 
    planet_osm_line.name, 
    st_multi(planet_osm_line.way)::geometry(MultiLineString, 2193) as way
  FROM planet_osm_line
  WHERE planet_osm_line.highway = ANY (ARRAY['motorway_link'::text, 'trunk'::text, 'primary'::text]);
--delete from trunk_primary where not st_intersects(st_centroid(geom), (ST_CollectionHomogenize(ST_Collect(ARRAY(select geom from country)))));

drop table if exists water;
create table water(
  id serial not null primary key,
  osm_id integer,
  name text,
  geom geometry(multipolygon, 2193)
);
create index gix_water on water using gist(geom);
delete from water;
insert into water(osm_id, name, geom) 
  SELECT planet_osm_polygon.osm_id, 
    planet_osm_polygon.name,  
    st_multi(planet_osm_polygon.way)::geometry(MultiPolygon, 2193) as way
  FROM planet_osm_polygon
  WHERE planet_osm_polygon."natural" = 'water'::text OR planet_osm_polygon.water IS NOT NULL OR planet_osm_polygon.waterway ~~ '%riverbank%'::text;
--delete from water where not st_intersects(st_centroid(geom), (ST_CollectionHomogenize(ST_Collect(ARRAY(select geom from country)))));

drop table if exists waterway;
create table waterway(
  id serial not null primary key,
  osm_id integer,
  name text,
  waterway text,
  geom geometry(multilinestring, 2193)
);
create index gix_waterway on waterway using gist(geom);
delete from waterway;
insert into waterway(osm_id, name, waterway, geom) 
  SELECT planet_osm_line.osm_id, 
    planet_osm_line.name,  
    planet_osm_line.waterway,
    st_multi(planet_osm_line.way)::geometry(MultiLineString, 2193) as way
  FROM planet_osm_line
  WHERE planet_osm_line.waterway = ANY (ARRAY['drain'::text, 'canal'::text, 'waterfall'::text, 'river'::text, 'stream'::text, 'yes'::text]);
--delete from waterway where not st_intersects(st_centroid(geom), (ST_CollectionHomogenize(ST_Collect(ARRAY(select geom from country)))));



