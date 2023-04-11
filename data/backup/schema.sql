


CREATE TABLE full_corpus(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER, short_source VARCHAR, source_bias VARCHAR, length_text INTEGER);
CREATE TABLE text_demos(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_cfr(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_fab(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_mani(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_urban(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_epi(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_am(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_disc(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_heritage(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_aei(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_cato(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_cap(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE sitemap_data(rowid INTEGER, url VARCHAR, lastmod TIMESTAMP, art_source VARCHAR);
CREATE TABLE linkchecker_data(rowid INTEGER, url VARCHAR, size INTEGER, result VARCHAR, art_source VARCHAR);
CREATE TABLE text_jacob(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_brook(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_cbpp(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_comf(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_merc(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_gutt(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_osf(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE source_table(art_source VARCHAR PRIMARY KEY, short_source VARCHAR, source_bias VARCHAR);
CREATE TABLE text_third(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_wilson(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);
CREATE TABLE text_iiss(art_link VARCHAR PRIMARY KEY, art_date DATE, art_author VARCHAR, art_title VARCHAR, art_source VARCHAR, full_text VARCHAR, pull_index INTEGER);


CREATE UNIQUE INDEX text_wilson_idx ON 'text_wilson' (art_link, art_source);
CREATE UNIQUE INDEX text_urban_idx ON 'text_urban' (art_link, art_source);
CREATE UNIQUE INDEX text_third_idx ON 'text_third' (art_link, art_source);
CREATE UNIQUE INDEX text_osf_idx ON 'text_osf' (art_link, art_source);
CREATE UNIQUE INDEX text_merc_idx ON 'text_merc' (art_link, art_source);
CREATE UNIQUE INDEX text_mani_idx ON 'text_mani' (art_link, art_source);
CREATE UNIQUE INDEX text_jacob_idx ON 'text_jacob' (art_link, art_source);
CREATE UNIQUE INDEX text_iiss_idx ON 'text_iiss' (art_link, art_source);
CREATE UNIQUE INDEX text_heritage_idx ON 'text_heritage' (art_link, art_source);
CREATE UNIQUE INDEX text_gutt_idx ON 'text_gutt' (art_link, art_source);
CREATE UNIQUE INDEX text_fab_idx ON 'text_fab' (art_link, art_source);
CREATE UNIQUE INDEX text_epi_idx ON 'text_epi' (art_link, art_source);






CREATE UNIQUE INDEX source_idx ON source_table (art_source);


CREATE UNIQUE INDEX site_idx ON sitemap_data (url, art_source);


CREATE UNIQUE INDEX link_idx ON linkchecker_data (url, art_source);
CREATE UNIQUE INDEX text_aei_idx ON 'text_aei' (art_link, art_source);
CREATE UNIQUE INDEX text_am_idx ON 'text_am' (art_link, art_source);
CREATE UNIQUE INDEX text_brook_idx ON 'text_brook' (art_link, art_source);
CREATE UNIQUE INDEX text_cap_idx ON 'text_cap' (art_link, art_source);
CREATE UNIQUE INDEX text_cato_idx ON 'text_cato' (art_link, art_source);
CREATE UNIQUE INDEX text_cbpp_idx ON 'text_cbpp' (art_link, art_source);
CREATE UNIQUE INDEX text_cfr_idx ON 'text_cfr' (art_link, art_source);
CREATE UNIQUE INDEX text_comf_idx ON 'text_comf' (art_link, art_source);
CREATE UNIQUE INDEX text_demos_idx ON 'text_demos' (art_link, art_source);
CREATE UNIQUE INDEX text_disc_idx ON 'text_disc' (art_link, art_source);


