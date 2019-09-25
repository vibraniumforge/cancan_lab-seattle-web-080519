# CancanCan Secret Notes

## Objectives

1. Understand how to create an Ability class.
2. Learn how to model permissions in the database.
3. Prevent users from accessing certain actions from the controller.
4. Prevent users from seeing certain pieces of the view.

## Overview

We're going to learn how to integrate [CanCanCan] into a Rails application. Our
authorization model for this example will be a message board for secret notes.

## Instructions

1. Create a `User` model and migration with attributes
   * `name`, a `String`
   * We're setting aside configuring passwords with `has_secure_password` in
     this lab. To include that would bring in details around managing session
     etc. which makes CanCanCan harder to understand. In a real application, you
     want _authentication_ from `has_secure_password` and BCrypt _as well as_
     _authorization_ from CanCanCan.
2. Create a `Note` model and migration with attributes
   * `content`, a `String`
   * `user_id`, an integer pointing to their creating `User`'s `id`.
3. Create a `Viewer` model and migration
   * `viewer` is a join between `notes` and `users` and will thus have their
     foreign keys (`user_id`, `note_id`) as `Integer` attributes
4. Boilerplate code. This lab has certain assumptions, the following should be
   put into your model definitions
```ruby
   # user.rb
   has_many :viewers
   has_many :readable, through: :viewers, source: :note

   # note.rb
   has_many :viewers
   has_many :readers, through: :viewers, source: :user
```
5. When we create a new note, we'll want a form that takes in a comma-separated
   list of usernames which represent who that note is visible to. To make
   certain operations easier, we want to create two utility methods:
   *  `visible_to`
     * Takes no arguments
     * Returns the readers' `name` `String`s, joined by a comma (with no space!)
   * `visible_to=(comma_string)`
     * Takes one argument, a `String`, joined by a comma (with **possible** spaces!)
     * Assings readers based on finding the `User`s whose names match the names
       extracted from `comma_string`.
     * Returns the readers' `name` `String`s, joined by a comma (with no space!)
6. You should  use the same principles of mass assignment to transfer
   parameters from the controllers to the model. Use the tests as your guide.
7. Speaking of controllers, create them.
   * We'll need a `NotesController` at the very least.
   * Any other controllers you need to achieve the goal
5. Add [CanCanCan] to your Gemfile and `bundle install`
6. Generate a skeleton `Ability` model with `rails g cancan:ability`
   * Write authorization rules in the `Ability` model. This is challenging. Consult [the documentation here][defining_abilities]
   * The rules are a little bit tricky because you have to look through an
     association to figure out if a user can read a note. You'll want to use a
     block condition, like this:
```ruby
    can :read, Note do |note|
      # TODO
    end
```
   to resolve the TODO, think about the following facts
     * CanCanCan gives you a `user` variable that's "visible" inside the `can`
       block
     * Inside the block you have access to a `note` variable
     * What's the relationship between a `Note` and a `User`. What associations
       or methods are present that will help you determine whether the `User`
       should read the `Note`? You can use enumerables or loops to return a `truthy`
       value which tells Rails "permission granted."
     

## Resources
[Sitepoint - CanCanCan: The Rails Authorization Dance](http://www.sitepoint.com/cancancan-rails-authorization-dance/)

<p data-visibility='hidden'>View <a href='https://learn.co/lessons/cancan_lab'>Cancan Lab</a> on Learn.co and start learning to code for free.</p>

[CanCanCan]: https://github.com/CanCanCommunity/cancancan
[defining_abilities]: https://github.com/CanCanCommunity/cancancan/wiki/defining-abilities
