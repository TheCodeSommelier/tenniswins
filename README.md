# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## SCSS Conventions

```c-dashboard``` == Container Dashboard\n
```__element``` == Element\n
```--modifier``` == Modifier\n

```
  .c-button {

    /* Element -- will result in a class c-button__anchor */
    &__anchor {
      /* styles here */
    }

    /* Modifier -- will result in a class c-button--outline */
    &--outline {
      /* styles here */
    }
  }
```
