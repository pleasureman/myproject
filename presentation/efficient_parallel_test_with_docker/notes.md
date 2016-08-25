Again thank you to Mark. Thank you to the dockercon organizers. Thank you to my team who is here some of them are sitting in front. I might be the one on stage but certainly everything that I'm going to talk about during this talk is the result of a group effort and I'm really proud of the way that we all work together.

So thank you so much and I have some former co-workers here as well so I'm feeling the love. My name is Laura again, a senior engineer at codeship and for the next 45 minutes prepare to have your mind blown. We're going to talk about parallel testing with docker.

So at codeship if you're not familiar with us, with CI(continous integration) and CD(continous delivery) accompany we focus on automating your tests and your deployment so that you can spend more time focusing on writing code and less time worrying about messing with servers and production.

Aside from that I'm a docker captain and you may have heard some docker captain charter. Maybe even met some mysterious creatures called docker captains. So we are meant to be kind of representation of the docker community. Lots of us have been working with docker for a very very long time.

If you are a newbie to docker. We would love to talk to you any questions that you have. No question is too simple and so please find us. A lot of us are wearing black hoodies that have little darker seagulls on them that's the captain marker. So feel free to say hi to us.

Before I was that coach, I worked for a really small research and development company. Our research and development team are part of the Century Link which some of you might know is a big telco provider and they wanted to have some senior engineers working on really cool projects and it just so happened that docker was part of that. So I worked on panamax and image layers which are two docker tools that you maybe have heard of(???). If you were(???) into docker kind of before it blew up and in big ways and before that i was at HP Helion in the infrastructure engineering team.

so I have a lot of experience with virtualization and then more specifically in the last two years with docker. And that's a bit of context for what I'm going to talk to you about. Today which is parallel testing and how we can make it better with docker? We'll talk about the goals and the benefits of parallel testing. Why we wanted in the first place?

we'll look at an implementation with LXC alone. So before docker and then finally we'll see what it looks like and what it feels like as an engineer and as a consumer of the platform when we introduce docker and tools from the docker ecosystem into the platform.

So let's get started simply by thinking about what it is we want to build in the first place. And throughout this talk what I'm going to focus on this mysterious platform that will talk about is a customizable very flexible build environment that can help us run tests in parallel.

-->2:42

So that's the goal of what I'm going to be trying to build. And We'll talk about the different ways that we can build this platform using docker and using LXC. So we want to be able to have full control over our testing environment and then be able to run tests quickly in parallel. And why do we want to do this? There's a couple of reasons. The most probably the most immediate one that comes to mind is that you just don't want to spend so much time waiting for your builds to build.

You want to be able to not only deploy your code to production fastest so that you have your best code in front of your customers immediately as soon as possible. And on the other side of that if something does go wrong you want to be alerted of that sooner so that you can correct your course(???), fix the mistake and then get moving and not have to worry about shipping bad code production or waiting really long for your feedback cycles.

If you still don't think automated testing or software testing in general is worth your time, this talk may not be for you and please
come and see me like after class in the coaches booth and we can talk about her like testing in general not as an employee of CI or CD accompany but just like as a software professional.

I would love to talk to you about why you think testing is is not important. That wasn't a threat I promise and very friendly. Uh-huh. So we want to have really short feedback cycles and and on the other side we want to be able to have full autonomy over every single thing that's going to run during our automated testing steps.

So this means when the tasks are run, what services are run, how the dependencies are managed. Everything that you could possibly imagine related automated testing steps I want absolute full control. If we think about why and then what Solomon said this morning about eliminating the friction in the development cycle. That's really what we're trying to do here so parallel testing is just one way that we can eliminate friction in the development cycle and kind of make everything just works so that you don't have to worry about it.

And we'll take this idea of a parallel testing platform, a couple different places that you might use it. So as I mentioned codeship is a hosted solution you can maybe have your own CI or CD solution those are places you could use a parallel testing platform. You can certainly also use it locally and demo using it locally as well.

So I like to always run my tests before I push anything to even a feature branch. Some of my colleagues are some people I worked with in the past prefer to rely on CI or CD to run builds for them. It doesn't matter whatever you prefer as long as you're running tests.

So when I run my tests locally before pushing things up I want them to run really really fast.

85
00:05:15,870 --> 00:05:19,890



















