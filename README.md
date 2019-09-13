Newspaper Works for Samvera
===================================================
Code:
[![Build Status](https://travis-ci.org/marriott-library/newspaper_works.svg?branch=master)](https://travis-ci.org/marriott-library/newspaper_works) [![Coverage Status](https://coveralls.io/repos/github/marriott-library/newspaper_works/badge.svg?branch=rubocop-cleanup)](https://coveralls.io/github/marriott-library/newspaper_works?branch=rubocop-cleanup)

Docs:
[![Apache 2.0 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE)
[![Contribution Guidelines](http://img.shields.io/badge/CONTRIBUTING-Guidelines-blue.svg)](./.github/CONTRIBUTING.md)

Jump in: [![Slack Status](http://slack.samvera.org/badge.svg)](http://slack.samvera.org/)

<!-- TOC -->

- [Introduction](#introduction)
  - [Documentation](#documentation)
- [Overview](#overview)
  - [Purpose, Use, and Aims](#purpose-use-and-aims)
  - [Development Status](#development-status)
  - [Requirements](#requirements)
  - [Newspaper_works Dependencies](#newspaper_works-dependencies)
- [Installing, Developing, and Testing](#installing-developing-and-testing)
  - [Extending and Using](#extending-and-using)
    - [Ingest, Application Interface](#ingest-application-interface)
  - [Basic Model Use (console)](#basic-model-use-console)
  - [Newspapers PCDM metadata model](#newspapers-pcdm-metadata-model)
  - [Application/Site Specific Configuration](#applicationsite-specific-configuration)
    - [Config changes made by the installer:](#config-changes-made-by-the-installer)
    - [Configuration changes to _config/intitializers/hyrax.rb_ you should make after running the installer:](#configuration-changes-to-_configintitializershyraxrb_-you-should-make-after-running-the-installer)
    - [Configuration changes to _config/environments/production.rb_ you should make after running the installer:](#configuration-changes-to-_configenvironmentsproductionrb_-you-should-make-after-running-the-installer)
  - [Development and Testing with Vagrant](#development-and-testing-with-vagrant)
    - [Host System Requirements (install these before proceeding)](#host-system-requirements-install-these-before-proceeding)
    - [Test Environment Setup (provisioning of virtual machine)](#test-environment-setup-provisioning-of-virtual-machine)
    - [Using/testing the Newspaper_works application with Vagrant](#usingtesting-the-newspaper_works-application-with-vagrant)
  - [Development and testing setup](#development-and-testing-setup)
- [Acknowledgements](#acknowledgements)
  - [Sponsoring Organizations](#sponsoring-organizations)
  - [Contributors and Project Team](#contributors-and-project-team)
  - [More Information](#more-information)
  - [Contact](#contact)

<!-- /TOC -->

# Overview
The Newspaper Works gem provides work type models and administrative functionality for Hyrax-based Samvera applications in the space of scanned newspaper media.  This gem can be included in a Digital Asset Management application based on Hyrax 2.5.x

A complete list of the features for available in Newspaper_works can be found [here](https://github.com/marriott-library/newspaper_works/wiki/Features-Matrix)

## Documentation
We are currently working on adding and updating documentation on our [Project Wiki](https://github.com/marriott-library/newspaper_works/wiki)

## Purpose, Use, and Aims
This gem, while not a stand-alone application, can be integrated into an application based on Hyrax 2.5.x easily to support a variety of cases for management, ingest, and archiving of primarily scanned (historic) newspaper archives.

## Requirements

  * [Ruby](https://rubyonrails.org/) >=2.4
  * [Rails](https://rubyonrails.org/) 5.1.7
  * [Bundler](http://bundler.io/)
  * [Hyrax](https://github.com/samvera/hyrax) 2.5.x
    - ..._and various [Samvera dependencies](https://github.com/samvera/hyrax#getting-started) that entails_.
  * A Hyrax-based Rails application.
    * Newspaper_works is a gem/engine that can extend your Hyrax application.

## Newspaper_works Dependencies

  * [FITS](https://projects.iq.harvard.edu/fits/home)
  * [Tesseract-ocr](https://github.com/tesseract-ocr/)
  * [LibreOffice](https://www.libreoffice.org/)
  * [ghostscript](https://www.ghostscript.com/)
  * [poppler-utils](https://poppler.freedesktop.org/)
  * [GraphicsMagick](http://www.graphicsmagick.org/)
  * [libcurl3](https://packages.ubuntu.com/search?keywords=libcurl3)

# Installing, Developing, and Testing
Newspaper_works easily integrates with your Hyrax 2.5.x applications.

A public testing site is available for those interested in testing out the newspaper_works gem. [Newspaper Works Demo Site](https://newspaperworks.digitalnewspapers.org/) **NOTE:** The demo site may not be running the latest release of Newspapers_Works.

## Extending and Using

* Add `gem 'newspaper_works', :git => 'https://github.com/marriott-library/newspaper_works.git'` to your Gemfile.
* Run `bundle install`
* Run `rails generate newspaper_works:generate`

### Ingest, Application Interface

_See [wiki](https://github.com/marriott-library/newspaper_works/wiki)_.

## Basic Model Use (console)

_More here soon!_

## Newspapers PCDM metadata model
[Detailed metadata model documents](https://wiki.duraspace.org/display/samvera/PCDM+metadata+model+for+Newspapers)

## Application/Site Specific Configuration

#### Config changes made by the installer:
* In `app/controllers/catalog_controller.rb`, the `config.search_builder_class` is set to a new `CustomSearchBuiler` to support newspapers search features
* Additional facet fields for newspaper metadata are added to `app/controllers/catalog_controller.rb`
* Newspaper resource types added to `config/authorities/resource_types.yml`

(It may be helpful to run `git diff` after installation to see all the changes made by the installer.)

#### Configuration changes to _config/intitializers/hyrax.rb_ you should make after running the installer:

* set `config.geonames_username` Enables geonames [username for Geonames](http://www.geonames.org/login
* set `config.work_requires_files = false`
* set ` config.iiif_image_server = true`
* set `config.fits_path = /location/of/fits.sh`

#### Configuration changes to _config/environments/production.rb_ you should make after running the installer:

* set `config.public_file_server.enabled = true`

* NewspaperWorks overrides Hyrax's default `:after_create_fileset` More infomation can be found [here](https://github.com/marriott-library/newspaper_works/wiki/File-Attachment-Notes)

## Developing and Testing with Vagrant

A VM has been created for users and developers to quickly and easily deploy the latest newspaper_works codebase using vagrant and virtual box. Additional information can be found by heading over to the [samvera-newspapers-vagrant](https://github.com/marriott-library/samvera-newspapers-vagrant) github project.

Additional information regarding development and testing environments setup and configuration can be found [here](https://github.com/marriott-library/newspaper_works/wiki/Installing,-Developing,-and-Testing)

# Contributing to Newspaper Works
We encourage anyone who is interested in newspapers and Samvera to contribute to this project. [How can I contribute?](https://github.com/samvera/hyrax/blob/master/.github/CONTRIBUTING.md)

# Acknowledgements
## Sponsoring Organizations

This gem is part of a project developed in a collaboration between [The University of Utah](https://www.utah.edu/), [J. Willard Marriott Library](https://www.lib.utah.edu/) and [Boston Public Library](https://www.bpl.org/), as part of a "Newspapers in Samvera" project grant funded by the [Institute for Museum and Library Services](https:///imls.gov).

The development team is grateful for input, collaboration, and support we receive from the Samvera Community, related working groups, and our project's advisory board.

## Contributors and Project Team

  * [Eben English](https://github.com/ebenenglish) (Boston Public Library)
  * [Brian McBride](https://github.com/brianmcbride) (University of Utah)
  * [Jacob Reed](https://github.com/JacobR) (University of Utah)
  * [Sean Upton](https://github.com/seanupton) (University of Utah)
  * Harish Maringanti (University of Utah)

## More Information
 * [Samvera Newspapers Group](https://wiki.duraspace.org/display/samvera/Samvera+Newspapers+Interest+Group) - The Samvera Newspapers Interest groups meets on the first Thursday of every month to discuss the Samvera newspapers project and general newspaper topics.
 * [Newspapers in Samvera IMLS Grant (formerly Hydra)](https://www.imls.gov/grants/awarded/lg-70-17-0043-17) - The official grant award for the project.
 * [National Digital Newspapers Program NDNP](https://www.loc.gov/ndnp/)

## Contact
 Contact any contributors above by email, or ping us on [Samvera Community Slack channel(s)](http://slack.samvera.org/)

![Institute of Museum and Library Services Logo](https://imls.gov/sites/default/files/logo.png)

![University of Utah Logo](http://www.utah.edu/_images/imagine_u.png)

![Boston Public Library Logo](https://cor-liv-cdn-static.bibliocommons.com/images/MA-BOSTON-BRANCH/logo.png?1528788420451)

This software has been developed by and is brought to you by the Samvera community.  Learn more at the
[Samvera website](http://samvera.org/).

![Samvera Logo](https://wiki.duraspace.org/download/thumbnails/87459292/samvera-fall-font2-200w.png?version=1&modificationDate=1498550535816&api=v2)
