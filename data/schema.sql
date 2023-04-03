


CREATE TABLE text_cbpp(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_comf(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_merc(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_gutt(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE source_table(art_source art_source, short_source short_source, source_bias source_bias);
CREATE TABLE sitemap_data(rowid INTEGER, url VARCHAR, lastmod TIMESTAMP, art_source art_source);
CREATE TABLE linkchecker_data(rowid INTEGER, parentname VARCHAR, result VARCHAR, infostring VARCHAR, url VARCHAR, size VARCHAR, art_source art_source);
CREATE TABLE text_osf(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_disc(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_am(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_epi(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_urban(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);


CREATE UNIQUE INDEX source_idx ON source_table (art_source);
CREATE UNIQUE INDEX site_idx ON sitemap_data (url, art_source);
CREATE UNIQUE INDEX link_idx ON linkchecker_data (url, art_source);


