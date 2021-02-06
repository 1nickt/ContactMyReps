#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib '/Users/1nickt/dev/p5-Net-Google-CivicInformation/lib';
use lib "$FindBin::Bin/../lib";

use ContactMyReps;
ContactMyReps->to_app;
