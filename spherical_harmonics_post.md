---
title: "Posy's Motion Amplification: Part 1"
layout: post
author: Martino Trapanotto
tags: [motion_extraction, python, computer vision]
katex: true
---


# Spherical Harmonics: A Likely wrong intro

Instead of starting to work on my master thesis, i decided to read a bit about Gaussian Splatting, and as i read some code and papers, i read quite a fre references to a concept called Spherical Harmonics. 

So as an aside to the aside, i tried reading the WIkipedia page. I understood very little.

I know what some of the words means, such as reference sto fourier transforms and what many of the mathematical tools used might mean, but it didn't really ease me into the topic. Thankfully a couple blogposts and some visualization aides helped very much.

So to summarize, SPherical Harmonics translate the ideas of decomposing a function from the 1D version of Fourier Series into 3D, by considering functions that apply on a unit sphere's surface. The basis that is used to decompose the iniut function is the harmonics that we are talking about now.

My first desire was first to visualize some of them, then perhaps learn how to decompose them

Let's start with understanging more and drawing

## Polar coordinates and Vertex Shaders

I like to do these things in LOVR, so that i can both see them in 3D and VR, adn not have to uss to much to use Shaders

Vertex shaders allow us to manipulate 3D vertices in batches, using the GPU, so this is very efficent, or would be if we processed hundreds of spheres together. as long as we use only a hanful of points it really does not matter


