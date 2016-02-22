The KBS LTER Metadata System
===========================

The metadata system employed by the Kellogg Biological Station Long Term Ecological Research Program

Copyright @2010 Michigan State Trustees

Design
-----

The system is modeled loosely on the EML schemas dataset, datatable, person and protocol modules. Datatables are the central feature
linking the other parts of the system togther. Multiple, hopefully related,  datatables are contained within a dataset. While both datasets
and datatables can have personel and protocols, we are migrating to the linking personel and protocols with datatables and then
computing the values for the datasets from the datatables.

Setup
-----

    git clone https://github.com/kf8a/metadata.git
    cd metadata
    bundle

Copy the config/database.yml.example to config/database.yml and fill in the local values for the database to be used

    rake db:migrate
    rails s


