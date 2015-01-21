Welcome to heroku-hook!
=======================

.. warning::
   This documentation is Work in Progress, many features may be documented but not implemented, or other way around.

Heroku-hook is a simple set of scripts, which connects heroku buildpacks to your hosted repositories.

What heroku-hook is not
-----------------------

Please be aware, that Heroku itself is way more sophisticated, and this project is not even close to be an Open-Source
alternative (yet). For example it is not supporting virtual containers, so every project lives in separate directory
(however due to structure of heroku buildpacks, each has it's own web-server). Also, definitely it shouldn't be
considered production ready - however it behaves pretty well if you need a quick solution, for your own staing or
client-preview server.


.. toctree::
   :hidden:

   quickstart

:doc:`quickstart`
   How to setup a fully working server in minutes

