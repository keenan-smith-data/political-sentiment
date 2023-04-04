


CREATE TABLE source_table(art_source VARCHAR PRIMARY KEY, short_source VARCHAR, source_bias VARCHAR);
CREATE TABLE text_osf(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_gutt(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_merc(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_comf(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_cbpp(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_mani(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_urban(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_epi(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_am(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_disc(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_aei(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_hrw(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_cato(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_heritage(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_cap(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE sitemap_data(rowid INTEGER, url VARCHAR, lastmod TIMESTAMP, art_source VARCHAR);
CREATE TABLE linkchecker_data(rowid INTEGER, url VARCHAR, size INTEGER, result VARCHAR, art_source VARCHAR);
CREATE TABLE text_jacob(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_brook(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);


CREATE UNIQUE INDEX source_idx ON source_table (art_source);
CREATE UNIQUE INDEX link_idx ON linkchecker_data (url, art_source);
CREATE UNIQUE INDEX site_idx ON sitemap_data (url, art_source);


