The KBS LTER Data Catalog System
===========================

This is the rails program that powers the data catalog system used by the Kellogg Biological Station Long Term Ecological Research Program. http://lter.kbs.msu.edu/datatables

Copyright @2010 Michigan State Trustees

Design
-----

The system is modeled loosely on the [EML schema](https://knb.ecoinformatics.org/#external//emlparser/docs/eml-2.1.1/index.html) dataset, datatable, person and protocol modules.  The main parts of the system are:

- Dataset

  Datasets are the container of multiple datatables. This component groups datatables together, the datatables in the dataset are listed under "Related Tables" on the show page for the datatable. A dataset can be converted to an eml document by sending the `to_eml` message.

  The ``/datasets.xml` endpoint generates a [metacat style harvest list](http://databits.lternet.edu/spring-2005/eml-harvesting-ii-preparing-site-metadata-and-harvest-lists) of the public datasets that are marked "pasta ready" in dataset table.

- Datatable

  Datatables present one table of data to the user. They can be backed by a database table or view or a data url that points elsewhere.  Datatables describe the location of the data and how to retrieve it as well as a connection point for the list of variates associated with the table.

- Protocol

  A protocol is linked to datatables,they can also be linked to datasets but that usage is deprecated. For datasets the protocols of the datatables are collected and presented as a group.

- Person

  The Person model represents a person. It is associated through the association table with datasets, datatables, and protocols. Persons can have several roles.
  
- Citation

  The Citation model represents a publication such as a journal article.

Setup
-----

    git clone https://github.com/kf8a/metadata.git
    cd metadata
    bundle

Copy the config/database.yml.example to config/database.yml and fill in the local values for the database to be used

    rake db:migrate
    rails s

Then go to `http://localhost:3000/datatables

To test

    rake test
