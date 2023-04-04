


CREATE TABLE linkchecker_data(rowid INTEGER, url VARCHAR, size INTEGER, result VARCHAR, art_source VARCHAR);
CREATE TABLE sitemap_data(rowid INTEGER, url VARCHAR, lastmod TIMESTAMP, art_source VARCHAR);
CREATE TABLE source_table(art_source VARCHAR PRIMARY KEY, short_source VARCHAR, source_bias VARCHAR);
CREATE TABLE text_heritage(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);




