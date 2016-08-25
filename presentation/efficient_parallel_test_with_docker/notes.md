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

So that's the goal of what I'm going to be trying to build and
