Again thank you to Mark. Thank you to the dockercon organizers. Thank you to my team who is here. Some of them are sitting in front. I might be the one on stage but certainly everything that I'm going to talk about during this talk is the result of a group effort and I'm really proud of the way that we all work together.

So thank you so much and I have some former co-workers here as well so I'm feeling the love. My name is Laura again, a senior engineer at codeship. And for the next 45 minutes prepare to have your mind blown(???让自己进行头脑风暴). We're going to talk about parallel testing with docker.

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

So when I run my tests locally before pushing things up I want them to run really really fast. Parallel testing can help that happen. But how can we get to this point? This is a really challenging question and something that coach has been working on for quite a few years. If you look at testing tasks kind of as autonomous things, there's only so much you can do per task to really optimize them.

So you might kind of change the way you use timeouts and integration test. There's a couple of other things you have a bigger build machine for example but if you really want great optimization you have to stop thinking about just optimizing the tests themselves but
optimizing the platform that you run the tests on.

So what we're aiming for is something that looks a little bit like this. We want to be writing code. Push it to a repository github bitbucket and then be able to run a bunch of tasks in parallel that once those pass can kick off a deployment. So this is a very simple kind of distributed example of what the platform is going to provide for us and the way that we are going to do this is
by using something called task parallelism.

And if you studied CS you probably know all about parallelism. Task parallelism is running tasks across multiple processors in parallel environment so this is different than taking a big data set and running parallel computations. That's parallelism as well but task parallelism is kind of a flavor of that and the way we will achieve this is by using a distributed system.

So in this case our multiprocessor computer is really just a series of machines that are docker host and our processor is a container so think of a container as just something that's going to run a process for us and that's how we're going to enable ourselves to use
this idea of task parallelism with docker.

And this brings us to an important point because i think when a lot of us are starting out with docker and certainly I've given this definition and receive this definition before that docker containers are just pms(???). And you might be a really good explanation of docker for like your parents or your kayaking tour guide or someone that's not technical.

And you're trying to explain what it is that you do all day because they don't understand it. But if we keep thinking

119
00:07:28,849 --> 00:07:29,750
about this

120
00:07:29,750 --> 00:07:34,460
we can't really solve very complex
problems in unique ways until we kind of

121
00:07:34,460 --> 00:07:38,270
go do away with this container vm
mapping and start thinking about a

122
00:07:38,270 --> 00:07:40,940
container is just something that can run
a process for us

123
00:07:40,940 --> 00:07:44,719
so as you can see with this task
parallelism example the only way that we

124
00:07:44,720 --> 00:07:48,110
can even implement this is if we change
our thinking to think of containers as

125
00:07:48,110 --> 00:07:51,680
virtue not virtual machines but rather
processes that can just accomplished

126
00:07:51,680 --> 00:07:57,260
some amount of work for us but you might
think well and we really need containers

127
00:07:57,260 --> 00:07:58,280
for this at all

128
00:07:58,280 --> 00:08:02,359
why not just use the m's it seems like
the system can be implemented pretty

129
00:08:02,360 --> 00:08:04,340
easily just with virtual machines

130
00:08:04,340 --> 00:08:09,169
so that's true and and we probably could
do it but there are a couple other

131
00:08:09,169 --> 00:08:12,820
concerns that prevented us from doing
that and

132
00:08:12,820 --> 00:08:17,349
the main one was isolating the running
builds on infrastructure so coach of

133
00:08:17,350 --> 00:08:19,900
course we have customers that run
building our infrastructure you might

134
00:08:19,900 --> 00:08:23,380
have multiple development teams within
your organization that are running

135
00:08:23,380 --> 00:08:26,50
builds on the same infrastructure and
you really want to keep things separate

136
00:08:26,50 --> 00:08:30,730
because dependency management is a
challenge and has been a challenge for a

137
00:08:30,730 --> 00:08:31,690
long time

138
00:08:31,690 --> 00:08:35,710
hopefully up until the point you start
using docker it's also really hard to

139
00:08:35,710 --> 00:08:40,570
impose resource limits just with VMs
alone and the most important thing and

140
00:08:40,570 --> 00:08:43,870
it may be the sticking point for a lot
of us is that if you're using the m's

141
00:08:43,870 --> 00:08:47,200
your infrastructure is really
underutilized some people talk a lot

142
00:08:47,200 --> 00:08:51,400
about virtualization density so the
amount of a kind of services that you

143
00:08:51,400 --> 00:08:57,40
can run per unit of virtualization and
with VMs you have a kind of a one-to-one

144
00:08:57,40 --> 00:09:00,160
mapping so you need one BM for one
service that's not ideal

145
00:09:00,160 --> 00:09:05,380
we want multiple services running on one
vm so it seems like the containers are

146
00:09:05,380 --> 00:09:09,970
great great use case a great solution
for this use case so containers promised

147
00:09:09,970 --> 00:09:12,250
to help us impose resource limits

148
00:09:12,250 --> 00:09:16,60
increase virtualization density which is
great takes us money saves our customers

149
00:09:16,60 --> 00:09:20,890
money saves you money if you're using
this in a local system you can run

150
00:09:20,890 --> 00:09:24,699
isolated code so that you don't have to
worry about things kind of spaghetti

151
00:09:24,700 --> 00:09:25,660
eating together

152
00:09:25,660 --> 00:09:30,819
dependency management is much easier and
you can really count on consistency

153
00:09:30,820 --> 00:09:35,260
across build run so not just a single
development team running builds and

154
00:09:35,260 --> 00:09:39,460
having a reproducible consistent
environment but many developers running

155
00:09:39,460 --> 00:09:44,80
many builds on many machines they're all
going to be the same and using

156
00:09:44,80 --> 00:09:49,660
containers will help us implement this
parallel task platform or parallel task

157
00:09:49,660 --> 00:09:53,650
design that i talked about earlier
that's going to help us run tests much

158
00:09:53,650 --> 00:09:55,930
faster and have a much performance

159
00:09:55,930 --> 00:10:01,150
see I and see the automation system so
coach trips out to do this and you can

160
00:10:01,150 --> 00:10:04,150
do it yourself with Alexei and that's
what we did

161
00:10:04,750 --> 00:10:08,320
and if you're a coach Chip customer you
might not know or if you're familiar

162
00:10:08,320 --> 00:10:12,10
with coaches in the past that coach has
been using containers since the very

163
00:10:12,10 --> 00:10:17,830
beginning of the company and that might
be confusing or alarming or surprising

164
00:10:17,830 --> 00:10:21,280
in a good way to some of you because
coach of course existed before dr. did

165
00:10:21,280 --> 00:10:23,439
and how we arrived to use

166
00:10:23,440 --> 00:10:29,230
sexy might be a bit better understood if
we think about what was happening at the

167
00:10:29,230 --> 00:10:33,670
time when we started building the system
and designing the system so 2011 was the

168
00:10:33,670 --> 00:10:37,839
year that coach was founded and it was
also the year that we found photographic

169
00:10:37,840 --> 00:10:43,330
evidence of salty water flowing salty
water on Mars which was also exciting

170
00:10:43,330 --> 00:10:47,860
and maybe more important than coach it
being founded depending on the US and it

171
00:10:47,860 --> 00:10:51,820
was also the international year of
forest I had a really fun time wikipedia

172
00:10:51,820 --> 00:10:52,960
for the slide

173
00:10:52,960 --> 00:10:57,640
I don't know like how many countries
need to participate in something four to

174
00:10:57,640 --> 00:11:00,880
the international so i don't know if it
was like just canada and something else

175
00:11:00,880 --> 00:11:05,560
but it was the international year for us
and maybe most importantly it was

176
00:11:05,560 --> 00:11:08,140
relevant to what we're talking about
today

177
00:11:08,140 --> 00:11:14,350
so precise was released in early 2012
and in the months leading up to the

178
00:11:14,350 --> 00:11:15,610
release of precise

179
00:11:15,610 --> 00:11:20,20
there was a lot of talk and preparation
done because the promise of precise was

180
00:11:20,20 --> 00:11:23,590
easier LXE management so if you look
back in message boards and blog posts

181
00:11:23,590 --> 00:11:28,300
email chains etc starting maybe around
july or august you'll see a lot of

182
00:11:28,300 --> 00:11:34,300
chatter in sort of the developer
conscious about Alexei using alexs see

183
00:11:34,300 --> 00:11:37,689
the different ways that Alex you can
solve problems opposed to traditional

184
00:11:37,690 --> 00:11:45,610
bm's also the green bay packers in the
very early part of 2011 won the super

185
00:11:45,610 --> 00:11:49,930
bowl and I think that was probably the
most important thing to happen in in

186
00:11:49,930 --> 00:11:50,829
2011

187
00:11:50,830 --> 00:11:53,830
and if we think about all of these
things together

188
00:11:54,880 --> 00:12:00,10
maybe you could draw a conclusion about
why coach ship started to use containers

189
00:12:00,10 --> 00:12:04,960
lxc specifically and we'll just well I'm
going to take a drink water will you

190
00:12:04,960 --> 00:12:07,10
look at aaron rodgers

191
00:12:07,10 --> 00:12:10,310
oh no no no

192
00:12:10,310 --> 00:12:12,258
get out

193
00:12:12,259 --> 00:12:19,970
so probably didn't happen aaron rodgers
is like hey guys i'm going to use elysee

194
00:12:19,970 --> 00:12:23,569
and what we did we made the choice
because it seemed like the logical thing

195
00:12:23,569 --> 00:12:27,589
for us to do and check pot is our
classic infrastructure so this is what

196
00:12:27,589 --> 00:12:31,759
we built using alexs see it is still
running in production and its really

197
00:12:31,759 --> 00:12:36,649
really great and really powerful if you
want a really low friction easy to ramp

198
00:12:36,649 --> 00:12:37,160
up

199
00:12:37,160 --> 00:12:40,549
see i see the solution that you can kind
of get with like just a couple clicks

200
00:12:40,549 --> 00:12:46,579
just sort of does its work sets you up
and get out of the way and the reason

201
00:12:46,579 --> 00:12:50,478
that it's so easy to use is that we have
to compromise a little bit of

202
00:12:50,479 --> 00:12:54,529
flexibility so you don't have as
fine-grained control as you might have

203
00:12:55,279 --> 00:12:59,59
when we talk about our doctor system but
it's incredibly easy to use

204
00:12:59,629 --> 00:13:03,619
so this was a really really good product
for a lot of customers and it's still

205
00:13:03,619 --> 00:13:08,779
used very heavily today so we have a
kind of peek of around 40,000 bills per

206
00:13:08,779 --> 00:13:12,79
day and creeping up on eight million
build so this is not just like some

207
00:13:12,79 --> 00:13:17,388
little pet project that uses LXE sort of
as a novelty this is the bread and

208
00:13:17,389 --> 00:13:22,730
butter of coach Chip and by far our
heaviest use product and a bit more

209
00:13:22,730 --> 00:13:25,519
about the architecture and how it is
that we built this

210
00:13:25,519 --> 00:13:31,69
so basically we have containers that are
sort of universal containers and you can

211
00:13:31,69 --> 00:13:36,49
think of them as empty slots on a big
virtual machine and then you can run a

212
00:13:36,49 --> 00:13:40,730
build in an empty slot and given that
these are just slots and they're kind of

213
00:13:40,730 --> 00:13:43,609
their very flexible and you can swap
them out

214
00:13:43,609 --> 00:13:44,750
you can

215
00:13:44,750 --> 00:13:50,000
we introduced this idea of pipelines so
parallel see I using build pipelines so

216
00:13:50,000 --> 00:13:54,170
instead of running a build in slots
which is a container you can run some

217
00:13:54,170 --> 00:13:58,699
task or a group of tasks at the same
time and in theory you can have n

218
00:13:58,700 --> 00:14:03,740
pipelines running kind of an isolation
from one another as part of your build

219
00:14:03,740 --> 00:14:07,730
so these are the same service the same
source code but just splitting up your

220
00:14:07,730 --> 00:14:11,420
steps into separate pipelines and it
looks a little bit like this

221
00:14:12,140 --> 00:14:17,390
you have just a couple things running in
isolation sort of separately from one

222
00:14:17,390 --> 00:14:22,189
another but at the same time and then
provided those are successful you can

223
00:14:22,190 --> 00:14:25,370
cook off some some sort of deployment so
this is a very common workflow that are

224
00:14:25,370 --> 00:14:30,230
a lot of our customers use pretty simple
and you can imagine the LXE was a pretty

225
00:14:30,230 --> 00:14:35,90
good fit for accomplishing this model
here but we came across a couple

226
00:14:35,90 --> 00:14:44,270
limitations with using LXE alone and by
far the biggest problem is that we were

227
00:14:44,270 --> 00:14:47,810
using LXE to run customer bills but
chances are they were not using alexs

228
00:14:47,810 --> 00:14:51,170
seen development and they definitely
weren't using it in production

229
00:14:51,170 --> 00:14:56,689
so in the keynote this morning we talked
a bit about how galaxies previous to dr.

230
00:14:56,690 --> 00:15:01,670
was sort of arcane and only four elite
technological people and a lot of our

231
00:15:01,670 --> 00:15:06,319
users simply weren't using LXE and we
were the outlier and because of that it

232
00:15:06,320 --> 00:15:09,380
was really hard for our customers to
debug locally and it's a problem that we

233
00:15:09,380 --> 00:15:12,500
solved by introducing remote debugging
sessions which works just great

234
00:15:13,339 --> 00:15:17,240
and this kind of comes from the fact
that with LXE there's not a great usable

235
00:15:17,240 --> 00:15:20,180
interface between the user and the
container so it just wasn't really

236
00:15:20,180 --> 00:15:24,260
appealing to our customers to run alex c
and development and then in production

237
00:15:24,260 --> 00:15:29,660
and since we designed the system to be
sort of like static sighs slots on the

238
00:15:29,660 --> 00:15:32,510
vm resource consumption at times

239
00:15:32,510 --> 00:15:35,930
could be a little bit high or too high
for the work that I was doing since we

240
00:15:35,930 --> 00:15:39,439
didn't allow customers to sort of define
the dependencies and the services that

241
00:15:39,440 --> 00:15:43,940
they're running in the slots everything
sort of got a cookie cutter container

242
00:15:43,940 --> 00:15:48,50
allocated to it so it wasn't the most
flexible solution but it was really easy

243
00:15:48,50 --> 00:15:53,10
to use and in short when our customers
wanted docker

244
00:15:53,10 --> 00:15:57,120
and our customers began adopting docker
it was clear that with LXE alone we

245
00:15:57,120 --> 00:16:01,350
really weren't able to provide the most
efficient product for our customers and

246
00:16:01,350 --> 00:16:04,860
then also maybe more importantly for
ourselves because we have course uses

247
00:16:04,860 --> 00:16:10,950
testing platform when we're developing
an honor engineering team so we decided

248
00:16:10,950 --> 00:16:15,870
that doctor would be the best choice and
a great fit to solve some of the

249
00:16:15,870 --> 00:16:21,300
problems that we were having and just to
take us back around to the goal of what

250
00:16:21,300 --> 00:16:25,620
it is that we're trying to make is we're
trying to build a customizable flexible

251
00:16:25,620 --> 00:16:30,990
testing environment that allows us to
run tests in parallel and dr. help us do

252
00:16:30,990 --> 00:16:33,150
this and for a couple reasons

253
00:16:33,150 --> 00:16:37,470
even before one . no doctor was like a
very very clear choice that it was

254
00:16:37,470 --> 00:16:41,250
something that we should bet on doctor
came with a lot of support and tooling

255
00:16:41,250 --> 00:16:44,730
standardization and then more
importantly we have a community of

256
00:16:44,730 --> 00:16:48,000
really motivated developers so people
were really enthusiastic about using

257
00:16:48,000 --> 00:16:51,540
docker and we knew that it was something
that there would be a need for and that

258
00:16:51,540 --> 00:16:54,900
there was a you know a group that was
not being served by the tools that were

259
00:16:54,900 --> 00:16:56,250
available

260
00:16:56,250 --> 00:17:00,120
aside from that for from us on our
perspective

261
00:17:00,120 --> 00:17:04,650
docker allowed us to build a much better
platform then using LXE alone and i'm

262
00:17:04,650 --> 00:17:08,40
going to go into detail about that
platform how it works how it's different

263
00:17:08,40 --> 00:17:10,770
and then we'll see a demo of it for the
rest of the talk

264
00:17:10,770 --> 00:17:16,260
this is called coach jet is our doctor
platform and we decided instead of

265
00:17:16,260 --> 00:17:20,790
evolving our LXE platform just to start
over and build something brand new with

266
00:17:20,790 --> 00:17:23,940
dr. in mind with dr. as a first class
citizen

267
00:17:23,940 --> 00:17:28,620
so this is a doctor based testing
platform truly we started development in

268
00:17:28,620 --> 00:17:29,639
2014

269
00:17:29,640 --> 00:17:34,470
first beta was in 2015 and then just a
couple months ago in February of 2016 we

270
00:17:34,470 --> 00:17:39,180
officially launched jet or coaching
soccer platform to the world and this is

271
00:17:39,180 --> 00:17:43,560
really different and really unique from
the previous testing platform using LXE

272
00:17:43,560 --> 00:17:48,690
because this is built with docker in
order to support dr. workflows

273
00:17:48,690 --> 00:17:53,580
so with with this new product we assume
that you're using docker and development

274
00:17:53,580 --> 00:17:57,000
and we assume that you're using docker
in production and therefore can draw the

275
00:17:57,000 --> 00:18:01,80
conclusion and make the assumption that
you also want docker during your

276
00:18:01,80 --> 00:18:03,928
automated testing and deployment steps

277
00:18:03,929 --> 00:18:07,919
jet is ramping up and there's certainly
a lot of happy customers and and we use

278
00:18:07,919 --> 00:18:14,399
internally so we have at peak maybe
about 2.3 2.4 builds per day and then

279
00:18:14,399 --> 00:18:21,479
around 250,000 total builds a couple of
the tools that we use from docker in jet

280
00:18:21,480 --> 00:18:25,830
so in our coach of dr. platform there's
three main ones that I want to call out

281
00:18:25,830 --> 00:18:30,928
the first one and the most important one
is dr. compose and compose is it really

282
00:18:30,929 --> 00:18:35,940
was life-changing i guess in the in the
world of a developer who was using

283
00:18:35,940 --> 00:18:37,409
docker before

284
00:18:37,409 --> 00:18:41,999
fig and then when think came on the
scene it just really changed everything

285
00:18:41,999 --> 00:18:46,19
because there wasn't an easy way to
manage a bunch of services at once

286
00:18:46,19 --> 00:18:50,549
and of course we borrow the syntax force
step definition and service definition

287
00:18:50,549 --> 00:18:55,110
because it is so easy and friendly and
editable and readable and we did this on

288
00:18:55,110 --> 00:18:59,399
purpose because a lot of our users are
using compose and development so it made

289
00:18:59,399 --> 00:19:02,549
sense just to take that same service
definition and then also use it in the

290
00:19:02,549 --> 00:19:08,220
test step we integrate with dr. registry
we allow users to push and pull from the

291
00:19:08,220 --> 00:19:12,90
registry so you might pull an image down
as a service in your tests and then as a

292
00:19:12,90 --> 00:19:17,309
deployment step push up to the registry
in one . nine and lower and I guess an

293
00:19:17,309 --> 00:19:22,619
older we use the registry for remote
cashing this changed as of one . 10

294
00:19:22,619 --> 00:19:28,199
content-addressable release i will talk
more about that in the engineering

295
00:19:28,200 --> 00:19:34,889
challenges section of the talk after the
home and dr. for mac and windows is a

296
00:19:34,889 --> 00:19:40,110
really great tool not only for us so I
i'm an engineer and of course i use

297
00:19:40,110 --> 00:19:45,389
docker and development and I i love to
have the m's like everywhere and i use

298
00:19:45,389 --> 00:19:49,678
docker on lots of different kinds of
machines but dr. for mac and windows is

299
00:19:49,679 --> 00:19:52,619
just so easy because i don't have to
think about it anymore

300
00:19:52,619 --> 00:19:56,639
and also for our users they're able to
download the jetseal I which is free you

301
00:19:56,639 --> 00:20:00,479
don't need a coach Chip account to use
it and run your tests but they can just

302
00:20:00,480 --> 00:20:04,470
run their builds basically on their own
infrastructure and their own local host

303
00:20:04,470 --> 00:20:05,759
before pushing it up

304
00:20:05,759 --> 00:20:08,220
I mean it's much easier to debug this is
something that we really didn't have

305
00:20:08,220 --> 00:20:11,730
with LXE and just made everyone's lives
much easier

306
00:20:11,730 --> 00:20:17,700
the flow of running a build for running
automated testing with jet is pretty

307
00:20:17,700 --> 00:20:24,750
similar to other non doctor based cic
systems with a couple really important

308
00:20:24,750 --> 00:20:25,560
exceptions

309
00:20:25,560 --> 00:20:31,139
so we get your code from github or from
a bit bucket we we see that you have

310
00:20:31,140 --> 00:20:35,40
committed something and then we look at
the services file and kind of parse that

311
00:20:35,40 --> 00:20:39,389
out in a similar way of that dr. compose
would build your services so we start

312
00:20:39,390 --> 00:20:40,740
building your services

313
00:20:40,740 --> 00:20:44,550
either we pull down an image from the
docker hub or we use the dockerfile to

314
00:20:44,550 --> 00:20:45,659
build it for you

315
00:20:45,660 --> 00:20:48,750
and then once all of your services are
in place we can start running testing

316
00:20:48,750 --> 00:20:53,760
steps and each of your testing steps
gets its own environment and we'll see

317
00:20:53,760 --> 00:20:57,570
this in action in just a little bit and
when you're testing steps are finished

318
00:20:57,570 --> 00:20:58,830
everything is green

319
00:20:58,830 --> 00:21:03,990
then we can usually push to a registry
is part of a predefined deployment step

320
00:21:03,990 --> 00:21:07,740
so everything is pretty streamlined
really focused on docker and we're

321
00:21:07,740 --> 00:21:10,500
touching a couple different doctor
projects while we're doing it for a

322
00:21:10,500 --> 00:21:13,980
really kind of seamless experience for
the user

323
00:21:13,980 --> 00:21:17,820
the workflow tools that we get from
docker for that reason are just

324
00:21:17,820 --> 00:21:20,669
indispensable there's no way that we
could have built a product that works so

325
00:21:20,670 --> 00:21:26,280
well for so many people without docker
and specifically there's one thing that

326
00:21:26,280 --> 00:21:31,320
dr. allowed us to do that we weren't
able to do with alex c which was to

327
00:21:31,320 --> 00:21:38,340
vastly improve our parallel testing
workflow so when we introduce dr. we

328
00:21:38,340 --> 00:21:42,720
were able to add another layer of
complexity to our parallel testing

329
00:21:42,720 --> 00:21:46,530
workflow because dr. made it so easy to
manage services

330
00:21:46,530 --> 00:21:50,820
this was something that we didn't have
with LXE and if you remember back we had

331
00:21:50,820 --> 00:21:54,510
sort of like cookie cutter slots for
bills to run in but there wasn't much

332
00:21:54,510 --> 00:21:58,379
customizability when it came to which
services would be run with which

333
00:21:58,380 --> 00:22:00,420
dependencies at which point in time

334
00:22:00,420 --> 00:22:03,990
so what we did with the doctor platform
and because dr. made it so easy for us

335
00:22:03,990 --> 00:22:07,50
is that we were able to loosen the
coupling between the steps that were

336
00:22:07,50 --> 00:22:11,340
running to the build commands and then
also the services that were being used

337
00:22:11,340 --> 00:22:18,000
along with the step and now you can have
n pipelines or end build steps

338
00:22:18,000 --> 00:22:21,930
so maybe you have ten build steps and
then each of those steps you can define

339
00:22:21,930 --> 00:22:23,960
exactly which service they should run
again

340
00:22:23,960 --> 00:22:28,10
for example you might have integration
tests that certainly need your whole

341
00:22:28,10 --> 00:22:32,600
stock like web database read etc but if
you have a limiting step it doesn't make

342
00:22:32,600 --> 00:22:35,959
sense to run all of your lenders against
a whole stack because you just don't

343
00:22:35,960 --> 00:22:40,580
need all the stuff you just need the
source code with with dr. and with the

344
00:22:40,580 --> 00:22:44,600
new jet platform were able to give the
developer control to define that and to

345
00:22:44,600 --> 00:22:48,439
specifically say exactly which services
in which dependencies are run in

346
00:22:48,440 --> 00:22:50,720
conjunction with which build step

347
00:22:50,720 --> 00:22:55,160
the other thing that we introduced with
time management and relative time

348
00:22:55,160 --> 00:22:56,90
management

349
00:22:56,90 --> 00:22:59,689
so now we have a concept of parallel
steps and also cereal steps

350
00:22:59,690 --> 00:23:03,320
so along with being able to define
services you can also say at what point

351
00:23:03,320 --> 00:23:09,770
in time and what conditions a certain
step can be run on and to just give a

352
00:23:09,770 --> 00:23:14,660
bit more detail in context about both
services and steps services can be an

353
00:23:14,660 --> 00:23:18,770
image from a registry or from a docker
file and of course you can specify

354
00:23:18,770 --> 00:23:22,220
different doctor files per project and
that's a pretty common workflow to have

355
00:23:22,220 --> 00:23:26,390
a test dockerfile may be deployed
dockerfile development docker file etc

356
00:23:26,390 --> 00:23:30,200
so all of those things are supported you
can specify which one you want to build

357
00:23:30,200 --> 00:23:34,190
you can optimize the service for testing
tasks

358
00:23:34,190 --> 00:23:38,240
maybe by only copying certain
directories into the flat into the image

359
00:23:38,240 --> 00:23:43,310
that you need any other customizations
environment variables etc everything is

360
00:23:43,310 --> 00:23:48,379
in total control of the user as you
would expect with docker and then those

361
00:23:48,380 --> 00:23:52,550
services are used when you're running
build steps in each build stop gets an

362
00:23:52,550 --> 00:23:58,10
independent environment that is executed
in and again we introduce the idea of

363
00:23:58,10 --> 00:24:02,360
serial and parallel steps to give you
more control over which

364
00:24:03,120 --> 00:24:07,320
like what time in relationship to
another time

365
00:24:07,320 --> 00:24:10,950
your steps can be run so if you have a
deployment step

366
00:24:10,950 --> 00:24:15,120
that's a good step for a serial step
because you don't want it to run in

367
00:24:15,120 --> 00:24:17,520
parallel with potentially another
failing step

368
00:24:17,520 --> 00:24:21,450
so you have really high control over
what's running when with which services

369
00:24:21,450 --> 00:24:26,580
these steps have two functions primarily
you have run which is executing command

370
00:24:26,580 --> 00:24:27,449
against the service

371
00:24:27,450 --> 00:24:32,130
this is make test for example or pushing
to a registry so deployment stuff that

372
00:24:32,130 --> 00:24:36,270
has you know executed only when all of
your steps have passed and then you're

373
00:24:36,270 --> 00:24:40,350
pushing or uh an image to a registry in
order to kick off the deployment the

374
00:24:40,350 --> 00:24:43,649
best thing in my very very favorite
thing about jet and about this new

375
00:24:43,650 --> 00:24:46,980
doctor based platform is the tag on the
step

376
00:24:46,980 --> 00:24:50,280
so you can we do regex matching against
a certain tags so if you have a

377
00:24:50,280 --> 00:24:55,889
deployment step you can tag it to only
run on branches that match master or

378
00:24:55,890 --> 00:24:59,70
something that matches the format of a
numerical tag for release

379
00:24:59,70 --> 00:25:03,419
this is a really powerful way to control
may be pushing to the staging branch and

380
00:25:03,420 --> 00:25:05,910
having up a deployed to stage it
happening

381
00:25:05,910 --> 00:25:14,40
staging happen and then again later
having a having a deployment to to

382
00:25:14,40 --> 00:25:14,850
production

383
00:25:14,850 --> 00:25:18,750
so you can do all of this with tagging
and it becomes kind of a defined once

384
00:25:18,750 --> 00:25:23,580
and then fits all of your use cases and
if it still sounds maybe not super

385
00:25:23,580 --> 00:25:28,260
different from what the previous a
platform could do I just want to

386
00:25:28,260 --> 00:25:32,610
illustrate the the difference in time
and if you're not familiar with time

387
00:25:32,610 --> 00:25:38,610
series notation or time sequence
notation t1 is like time now and then t2

388
00:25:38,610 --> 00:25:44,280
is time now and then the next time so t1
t2 t3 or . and time that are happening

389
00:25:44,280 --> 00:25:47,879
sequentially and we can see all of this
is happening at t1 so this is happening

390
00:25:47,880 --> 00:25:49,620
at the exact same point in time

391
00:25:49,620 --> 00:25:53,639
this is the old system that was LXE
based we have pipelines user commands

392
00:25:53,640 --> 00:25:58,230
running inside of containers all at the
same time with dr. and the new parallel

393
00:25:58,230 --> 00:26:02,160
testing platform that we built with
docker we are able to not only control

394
00:26:02,160 --> 00:26:03,270
services

395
00:26:03,270 --> 00:26:08,520
the steps but also time which is pretty
cool so at T 1 we have a step that is

396
00:26:08,520 --> 00:26:10,940
running a command against the web
service

397
00:26:10,940 --> 00:26:15,260
and then on the very far left-hand side
you can see the web service has two

398
00:26:15,260 --> 00:26:17,360
dependencies postgres and redness

399
00:26:17,360 --> 00:26:23,389
so this is all defined by the user this
step is cereal if the stuff at t1 passes

400
00:26:23,390 --> 00:26:27,290
we moved to t2 t2 is two parallel steps
and you can see that the services are

401
00:26:27,290 --> 00:26:31,550
different the services are the light
blue boxes two steps happening in

402
00:26:31,550 --> 00:26:35,750
parallel but only when those two steps
past can we move to 23

403
00:26:35,750 --> 00:26:40,700
so this is a really powerful way to
configure your tests in order to make

404
00:26:40,700 --> 00:26:43,670
sure that you're doing exactly what you
want

405
00:26:43,670 --> 00:26:48,110
at what time you want things to happen
and if this sounds may be really

406
00:26:48,110 --> 00:26:52,850
intimidating like oh god how much code
am I gonna have to write the craters

407
00:26:52,850 --> 00:26:59,510
it's like really not a lot i'm going to
show you and the services file right now

408
00:26:59,510 --> 00:27:05,90
and then the steps file and it's small
enough that I can fit on a keynote slide

409
00:27:05,90 --> 00:27:07,159
so it's really not a lot

410
00:27:07,160 --> 00:27:10,910
this is a coach services file and if you
are familiar with dr. compose this

411
00:27:10,910 --> 00:27:13,160
probably looks really really familiar to
you

412
00:27:13,160 --> 00:27:16,730
and if you're not familiar with soccer
compose and maybe animal is new to you

413
00:27:16,730 --> 00:27:20,690
I just want to highlight that the most
important points to look at are the high

414
00:27:20,690 --> 00:27:26,930
level heading so DB app and then
deployment service so we have this in

415
00:27:26,930 --> 00:27:31,10
this service configuration we have a
database which is pulling an image from

416
00:27:31,10 --> 00:27:34,520
the docker hub then we have an app which
is our web service this is just a

417
00:27:34,520 --> 00:27:41,900
example of a i will use a small rails up
when I demo this could be could be any

418
00:27:41,900 --> 00:27:45,560
web app and this is linked to the
database and we see that in the links

419
00:27:45,560 --> 00:27:50,450
file or in the links declaration on the
very bottom of the app service and then

420
00:27:50,450 --> 00:27:53,390
finally a deploy service and we can
guess that this to play service is

421
00:27:53,390 --> 00:27:55,520
probably going to be used during it to
play step

422
00:27:55,520 --> 00:28:00,530
I do want to call out that this is
composed version 1 syntax and not

423
00:28:00,530 --> 00:28:01,430
version -

424
00:28:01,430 --> 00:28:03,500
there are a couple

425
00:28:03,500 --> 00:28:08,60
kind of a couple things were jet and
compose aren't in lockstep with each

426
00:28:08,60 --> 00:28:11,659
other simply because we extend compose
and don't use it directly and we're

427
00:28:11,660 --> 00:28:13,100
working on making parody

428
00:28:13,100 --> 00:28:19,939
I got a top priority given those
services we have steps so maybe I lied

429
00:28:19,940 --> 00:28:24,140
and we can't fit this whole thing on the
little narrow keynote side but I have

430
00:28:24,140 --> 00:28:27,590
some handy notations to make this a
little bit easier

431
00:28:28,190 --> 00:28:35,930
um this is a group of two serial steps
step 1 by the yellow one and then step 2

432
00:28:35,930 --> 00:28:40,490
by the yellow to within step one is
actually where all of my testing

433
00:28:40,490 --> 00:28:43,490
goodness is happening this is a group of
parallel steps

434
00:28:44,60 --> 00:28:49,460
so what I'm saying is that I want there
to be these for testing stops run in

435
00:28:49,460 --> 00:28:53,360
parallel and if and only if all of those
steps past

436
00:28:53,360 --> 00:28:58,909
do I want the second step to happen
which is my deploy and i'm also using

437
00:28:58,910 --> 00:29:01,70
tag in this deploy step

438
00:29:01,70 --> 00:29:05,480
so if this is any branch that's not
master or that doesn't match the regular

439
00:29:05,480 --> 00:29:10,10
expression that I've noted in the tag it
simply will not do but it won't deploy

440
00:29:10,10 --> 00:29:11,540
it won't execute

441
00:29:11,540 --> 00:29:16,550
so this is all of the configuration for
being able to run all of my test in an

442
00:29:16,550 --> 00:29:23,480
automatic way and then push my image up
to the dr hub again and i cannot stress

443
00:29:23,480 --> 00:29:24,410
this enough

444
00:29:24,410 --> 00:29:27,530
it's so fun to think about all the
possible configurations that you ever

445
00:29:27,530 --> 00:29:29,960
could do with serial and parallel
testing groups

446
00:29:29,960 --> 00:29:33,470
please do not make your deploy stop part
of a parallel testing group unless you

447
00:29:33,470 --> 00:29:37,250
know what you're doing and you probably
don't you think you do but you don't

448
00:29:37,250 --> 00:29:41,870
because you don't ever wanted to play
stuff to happen simultaneously with some

449
00:29:41,870 --> 00:29:45,679
other testing step that potentially
could fail but the deploy is still

450
00:29:45,680 --> 00:29:46,640
successful

451
00:29:46,640 --> 00:29:50,870
so if it's a parallel stuff there's no
like there's no guarantee that if the

452
00:29:50,870 --> 00:29:54,469
like that the deploy won't finish before
of a failed step and then you might end

453
00:29:54,470 --> 00:29:56,90
up with broken code in production

454
00:29:56,90 --> 00:30:02,629
so just a pro tip to avoid that and
let's check out with this looks and

455
00:30:02,630 --> 00:30:08,510
feels like with a live demo so I didn't
sacrifice to the demo gods but I did

456
00:30:08,510 --> 00:30:10,650
have coffee earlier today so i really
hope that

457
00:30:10,650 --> 00:30:19,380
all right you can see everything ok cool
make this a little bigger

458
00:30:22,200 --> 00:30:31,110
I'm gonna demo are really simple rails
application that i made for your

459
00:30:31,110 --> 00:30:31,979
enjoyment

460
00:30:31,980 --> 00:30:39,510
it's called notes app oh I'll make this
a little bigger so that you can see this

461
00:30:39,510 --> 00:30:44,100
is a really simple application and i'm
using docker composed to run it actually

462
00:30:44,100 --> 00:30:45,449
up already

463
00:30:45,450 --> 00:30:51,840
we can look at the dr compose file and
see that it's basically identical to

464
00:30:51,840 --> 00:30:55,949
what I had in my slides i have a web
application again this is a simple rails

465
00:30:55,950 --> 00:30:57,720
app running on port 3000

466
00:30:57,720 --> 00:31:01,530
I've mounted the volume and because this
is development and I want to be able to

467
00:31:01,530 --> 00:31:07,200
edit my code and i am using post-crisis
my database so this is running on port

468
00:31:07,200 --> 00:31:13,350
3000 and since I'm using docker for mac
i should be able to just say localhost

469
00:31:13,350 --> 00:31:20,70
3000 and see this running will refresh
it and we can see that it's there

470
00:31:20,70 --> 00:31:25,409
great all this is just like a little
tasks tracking app so i'll log in with

471
00:31:25,410 --> 00:31:30,390
my name and i can see that i have like
no sacrifice to the demo gods and drink

472
00:31:30,390 --> 00:31:35,40
some coffee so i can maybe mark the
coffee part i did that did that

473
00:31:35,550 --> 00:31:40,860
cool so I did that and I can add a new
task and maybe I notice i want to change

474
00:31:40,860 --> 00:31:46,469
something so we'll make an update will
change the text on this button seems

475
00:31:46,470 --> 00:31:48,150
seems simple enough

476
00:31:48,150 --> 00:31:50,880
so I open up my editor

477
00:31:50,880 --> 00:31:55,20
and updated and say like the task app so
maybe like do this thing

478
00:31:55,950 --> 00:32:03,150
please we'll save that and then you
should be able to see that

479
00:32:03,150 --> 00:32:06,210
okay great dr. Campos is working as you
expect

480
00:32:06,210 --> 00:32:11,460
so that's great and I maybe had a ticket
and pivotal tracker and I want to push

481
00:32:11,460 --> 00:32:23,250
this up and I'm going to see what's
going on with get and i'll add app and

482
00:32:23,250 --> 00:32:27,450
commit maybe updating button text

483
00:32:27,450 --> 00:32:33,870
sounds reasonable I'm going to push this
to Master only for educational purposes

484
00:32:33,870 --> 00:32:39,120
so please own don't you this but it's a
demo but before i do at least I have

485
00:32:39,120 --> 00:32:41,820
some kind of like discretion and
self-control

486
00:32:41,820 --> 00:32:45,750
I want to run my test locally and i'm
going to use the code ship docker

487
00:32:45,750 --> 00:32:51,780
platform jet the jetseal I that you can
download to run your tests in on your

488
00:32:51,780 --> 00:32:52,980
local machine

489
00:32:52,980 --> 00:32:56,760
it's free you don't need a coach up
account or anything and before we do

490
00:32:56,760 --> 00:33:01,110
that I just want to take a peek of at
the code ship services file

491
00:33:01,110 --> 00:33:04,860
so this is nearly identical to my
daugher compose file that we looked at

492
00:33:04,860 --> 00:33:09,780
that i'm using with dr. Campos right now
we have database a nap and then the

493
00:33:09,780 --> 00:33:13,530
second deploy service that will use in
my deploy step so these are exactly

494
00:33:13,530 --> 00:33:18,30
matching when I had in the slides
earlier we can look quickly at the coach

495
00:33:18,30 --> 00:33:19,680
Chip steps file as well

496
00:33:19,680 --> 00:33:23,760
this is the same situation where I have
to serial steps the first one is a

497
00:33:23,760 --> 00:33:31,740
parallel step group and then if that
succeeds then it goes to deploy since

498
00:33:31,740 --> 00:33:35,940
i'm pushing to master this is going to
execute immediately before this deploy

499
00:33:35,940 --> 00:33:40,980
step will execute because it matches the
the regular expression in the tag again

500
00:33:40,980 --> 00:33:44,370
educational purposes so that's a yellow

501
00:33:45,570 --> 00:33:49,980
if i can remember how to type up here

502
00:33:50,760 --> 00:33:56,700
cool so I'm pushing this up to github
and I have this project setup with code

503
00:33:56,700 --> 00:34:03,390
ship and I can take a peek and see that
my bill has been allocated and I can

504
00:34:03,390 --> 00:34:11,580
look at everything and see that hey it's
running this will take maybe about two

505
00:34:11,580 --> 00:34:15,270
minutes and dream that two minutes while
this is running

506
00:34:15,270 --> 00:34:19,380
I want to explain to you a little bit
how the deployment process is set up for

507
00:34:19,380 --> 00:34:23,130
this application using docker cloud

508
00:34:23,130 --> 00:34:27,900
so this is a really easy and flexible
and and pretty like fun and enjoyable

509
00:34:27,900 --> 00:34:30,930
when I am deploying pretty simple
applications i have this set up with

510
00:34:30,929 --> 00:34:34,889
coach Chip and you see that my testing
steps will run in parallel and then I

511
00:34:34,889 --> 00:34:39,449
push as my deployment step and I don't
do anything else because i have on dr.

512
00:34:39,449 --> 00:34:44,909
cloud this repository and this this
image set up as an auto redeploy

513
00:34:44,909 --> 00:34:49,469
application so every time I push an
image up to the dr hug the darker darker

514
00:34:49,469 --> 00:34:52,739
clouds sees that happens in
automatically redeploys my application

515
00:34:52,739 --> 00:34:57,149
using the new image and this application
is actually up and running now

516
00:34:57,750 --> 00:35:03,120
and if you want to go to dr. condemn
o.com which is the coolest domain i've

517
00:35:03,120 --> 00:35:05,100
ever purchased in my entire life

518
00:35:05,100 --> 00:35:12,390
you can check this out and in about a
minute and a half maybe we can see the

519
00:35:12,390 --> 00:35:16,950
new changes that are deployed using code
ship and then pushing an image

520
00:35:16,950 --> 00:35:20,189
dr. cloud takes it over from then and
then we have code deployed

521
00:35:20,190 --> 00:35:25,200
this was deployed also with coach Chip
and dr. cloud we can see we have eat the

522
00:35:25,200 --> 00:35:27,540
bacon by the Boston

523
00:35:27,540 --> 00:35:29,800
he loves bacon a lot

524
00:35:29,800 --> 00:35:34,690
Gordon the turtle get Michelle wax and a
couple other cast that I didn't finish

525
00:35:34,690 --> 00:35:39,310
we can check on our build still going

526
00:35:39,310 --> 00:35:42,790
maybe I want to see what's happening

527
00:35:42,790 --> 00:35:46,990
I can take a peek at the logs so every
single thing that I'm seeing here is

528
00:35:46,990 --> 00:35:51,640
exactly what i saw in my local
environment which is pretty cool and it

529
00:35:51,640 --> 00:35:57,310
makes my life as an engineer running my
test in containers between my

530
00:35:57,310 --> 00:36:01,930
development and production steps just
makes it a whole lot easier so we can

531
00:36:01,930 --> 00:36:05,319
see that some of these parallel tests
are finishing up and we're just sort of

532
00:36:05,320 --> 00:36:10,360
waiting for backup to finish and I think
actually is finished

533
00:36:10,360 --> 00:36:13,990
I just saw that the place to go green
but cool

534
00:36:13,990 --> 00:36:17,410
so now dr. Khan demo . com

535
00:36:17,410 --> 00:36:24,100
if i refresh this oh okay oh it's auto
redeploying right now okay I caught it

536
00:36:24,100 --> 00:36:28,870
at like the exact two seconds okay well
we'll wait and we'll come back to that

537
00:36:28,870 --> 00:36:32,770
right after but you start working before
you know that it works great

538
00:36:33,790 --> 00:36:38,860
I just want to say again that the the
reason this feels so nice and natural is

539
00:36:38,860 --> 00:36:40,990
that i'm using docker for mac and
windows

540
00:36:40,990 --> 00:36:44,950
this from an engineer's perspective is
probably the biggest advantage over

541
00:36:44,950 --> 00:36:48,759
using something using with LXE alone
because I can do everything locally

542
00:36:48,760 --> 00:36:53,830
before i push it up to infrastructure's
of two are hosted solution or maybe to

543
00:36:53,830 --> 00:36:58,660
your own solution internally and the
Jets Eli is free and you can pull it

544
00:36:58,660 --> 00:37:01,660
down to run your tests and it's
available at this bit ly

545
00:37:02,810 --> 00:37:08,60
coach object to link and this again huge
advantage over the previous LXE

546
00:37:08,60 --> 00:37:13,670
implementation a bit about some
engineering challenges because i don't

547
00:37:13,670 --> 00:37:16,370
want to stand up here and say that
adding dr. to your project is going to

548
00:37:16,370 --> 00:37:20,60
make everything like super happy and
perfect because it sometimes doesn't

549
00:37:20,690 --> 00:37:23,960
you still have really hard engineering
challenges that you need to solve but

550
00:37:23,960 --> 00:37:28,460
fact is dr. are usually makes it easier
or more straightforward to solve

551
00:37:28,460 --> 00:37:33,50
so one of our infrastructure problems
was built a location time and when we

552
00:37:33,50 --> 00:37:36,620
first built this platform we didn't have
a ton of customers and also we allow

553
00:37:36,620 --> 00:37:40,850
customers to define the specs for their
build machines so it just made sense to

554
00:37:40,850 --> 00:37:44,839
make the build machine a location part
of the build itself

555
00:37:45,650 --> 00:37:49,400
this turned out to be not the best
choice in the long run now that we have

556
00:37:49,400 --> 00:37:54,620
more customers and sometimes AWS is
really slow so waiting for the AWS

557
00:37:54,620 --> 00:38:01,279
machine to boot up with sometimes much
much longer than the build itself so we

558
00:38:01,280 --> 00:38:04,190
had some customers that have a bill that
takes 30 seconds

559
00:38:04,190 --> 00:38:07,550
but you have to wait 90 seconds for the
build machine so that's 90 wasted

560
00:38:07,550 --> 00:38:08,240
seconds

561
00:38:08,240 --> 00:38:11,299
the great news is that we fixed it and
now we pull build machines

562
00:38:11,300 --> 00:38:16,130
so now allocation time is just about one
second that was a not necessarily dr.

563
00:38:16,130 --> 00:38:19,550
related but certainly something when we
were building this platform places that

564
00:38:19,550 --> 00:38:25,460
we could optimize image caching is also
a really really big issue for us

565
00:38:25,460 --> 00:38:30,80
so as you can imagine build time is
paramount is the most important thing to

566
00:38:30,80 --> 00:38:35,720
us and to our customers and as I
mentioned before we used to rely on the

567
00:38:35,720 --> 00:38:37,40
registry for caching

568
00:38:37,40 --> 00:38:41,360
so if you pull down an image from the
registry you also got the parent images

569
00:38:41,360 --> 00:38:46,850
sort of the parent-child relationship as
part of that this isn't dr. 19 and and

570
00:38:46,850 --> 00:38:52,630
before and then if we rebuilt that same
image using a docker file that the

571
00:38:52,630 --> 00:38:58,360
and that the customer provided then the
cash would be would be used up until the

572
00:38:58,360 --> 00:39:01,870
point that couldn't be so doctor would
sort of decide which layer the cash was

573
00:39:01,870 --> 00:39:05,109
an invalid for and then rebuild
everything

574
00:39:05,110 --> 00:39:10,600
this changed with dr. 110 because of the
content addressable storage update so

575
00:39:10,600 --> 00:39:13,750
this is sort of a security focus update
that had some interesting input

576
00:39:13,750 --> 00:39:18,850
implications for us using the registry
as a remote caching source

577
00:39:19,660 --> 00:39:22,720
the great news is that in dr. 111

578
00:39:22,720 --> 00:39:25,450
there is a restoration of the
parent-child relationship when image

579
00:39:25,450 --> 00:39:31,120
layers are saved out as part of a doctor
save command and I have been working on

580
00:39:31,120 --> 00:39:36,819
designing this and now i'm seriously
coding along with my team to get this up

581
00:39:36,820 --> 00:39:41,350
and running and we should have new
cashing in about one month and this is

582
00:39:41,350 --> 00:39:44,950
sort of the double-edged sword of
relying on external tools so doctor did

583
00:39:44,950 --> 00:39:49,120
a lot for us but I think in any case if
something is so important having a third

584
00:39:49,120 --> 00:39:53,140
party dependencies like maybe not great
all the time so we are still going to

585
00:39:53,140 --> 00:39:57,310
rely on dr. save and load but a
different way and sort of less attached

586
00:39:57,310 --> 00:39:59,380
to the the core dr. functionality

587
00:39:59,380 --> 00:40:03,970
aside from those engineering challenges
we have a couple plans for things that

588
00:40:03,970 --> 00:40:08,319
are happening next so jet was born
priests warm and given the announcements

589
00:40:08,320 --> 00:40:12,130
today with dr. 112 were super super
excited for all of the changes and

590
00:40:12,130 --> 00:40:14,400
orchestration and using

591
00:40:14,400 --> 00:40:20,130
and possibly swarm is a way to manage
our machine so we manage them with a

592
00:40:20,130 --> 00:40:24,450
service that we sort of rolled our
ourselves we manage our machines in AWS

593
00:40:24,450 --> 00:40:28,919
and the idea of taking that away and
maybe moving to a swarm based solution

594
00:40:28,920 --> 00:40:33,240
is really exciting on their services
like Karina that could make this really

595
00:40:33,240 --> 00:40:37,770
easy for us and if you want to know more
about Karina which is like a darker

596
00:40:37,770 --> 00:40:41,640
swarm as a service sort of from
rackspace they have a booth here

597
00:40:41,640 --> 00:40:45,990
highly recommend that you go check it
out i think it's a super cool project we

598
00:40:45,990 --> 00:40:50,279
also really wanna introduce lib compose
into this project to make it even easier

599
00:40:50,279 --> 00:40:51,599
and to help track

600
00:40:51,599 --> 00:40:56,160
dr. compose a little bit more closely to
trunk and this is also one of those

601
00:40:56,160 --> 00:41:00,270
situations where we started development
before compose really existed before

602
00:41:00,270 --> 00:41:05,9
thing was you know in our hearts and
hearts and minds so we wrap the api's

603
00:41:05,10 --> 00:41:10,500
directly and this would be kind of a
minimal change for our end users because

604
00:41:10,500 --> 00:41:15,960
we are pretty supportive or maybe track
compose very closely as it is but for us

605
00:41:15,960 --> 00:41:18,599
as engineers that would just make this
so much easier

606
00:41:18,599 --> 00:41:23,730
implementing kind of a composed based
solution for the service declaration and

607
00:41:23,730 --> 00:41:26,460
we have started preliminary work on this
it doesn't have an ETA that i can

608
00:41:26,460 --> 00:41:29,880
announce yet but it is something that
we're hoping again this is not going to

609
00:41:29,880 --> 00:41:33,480
be a real big user-facing change but as
an engineer with something that's going

610
00:41:33,480 --> 00:41:35,220
to make my life a whole lot easier

611
00:41:35,220 --> 00:41:40,500
so long story short tldr if there's one
thing that you can remember from this

612
00:41:40,500 --> 00:41:45,210
talk that highly efficient parallel
testing is super cool and dr. makes it

613
00:41:45,210 --> 00:41:53,700
so much easier before I end let's see if
our friend is working again

614
00:41:53,700 --> 00:41:58,589
it looks like yes it's back up so
awesome yeah awesome great okay

615
00:41:59,340 --> 00:41:59,880
thank you so much



















