import 'package:flutter/material.dart';
import '../models/campus_content.dart';

// All entries are fictional demonstration data.
const announcements = <Announcement>[
  Announcement(
    id: 'library-hours',
    title: 'Extended library hours',
    category: 'Library',
    date: '2 November 2026',
    preview: 'Extra evening study time during revision week.',
    detail:
        'The campus library will stay open until 10 pm from 2 to 6 November. '
        'Quiet study areas and the computer room will be available. Bring your student card; '
        'the borrowing desk closes at 8 pm.',
  ),
  Announcement(
    id: 'wellbeing-workshop',
    title: 'Managing exam stress',
    category: 'Wellbeing',
    date: '3 November 2026',
    preview: 'Join a practical workshop on study routines and relaxation.',
    detail:
        'The counselling team is holding a workshop in Student Centre Room 2 '
        'on 3 November from 2 to 3 pm. Learn breathing exercises and build a realistic '
        'revision schedule. All students are welcome; arrive ten minutes early.',
  ),
  Announcement(
    id: 'residence-briefing',
    title: 'Residence safety briefing',
    category: 'Accommodation',
    date: '4 November 2026',
    preview: 'Residents can learn about evacuation routes and support.',
    detail:
        'Meet in the Residence A lobby at 6 pm on 4 November. The residence team '
        'will explain emergency exits, assembly points and maintenance reporting. '
        'The briefing lasts approximately 30 minutes.',
  ),
  Announcement(
    id: 'career-fair',
    title: 'Campus career fair',
    category: 'Careers',
    date: '5 November 2026',
    preview: 'Explore internships and practise introducing yourself.',
    detail:
        'Visit the Main Hall between 10 am and 4 pm on 5 November for the sample '
        'career fair. Bring a copy of your CV and prepare a short introduction. '
        'Career advisers will offer CV feedback at the entrance desk.',
  ),
  Announcement(
    id: 'sports-trials',
    title: 'Badminton team trials',
    category: 'Sports',
    date: '6 November 2026',
    preview: 'Players of all experience levels are invited to try out.',
    detail:
        'Badminton trials take place in the Sports Hall from 5 to 7 pm on '
        '6 November. Wear suitable sports shoes and bring water and a racket if '
        'you have one. Loan rackets are available at reception.',
  ),
  Announcement(
    id: 'network-maintenance',
    title: 'Campus Wi-Fi maintenance',
    category: 'IT',
    date: '7 November 2026',
    preview: 'Short connection interruptions are expected on Saturday.',
    detail:
        'The IT team will service campus Wi-Fi on 7 November from 8 to 10 am. '
        'Connections may briefly drop in academic buildings. Save online work '
        'before the maintenance window and reconnect after the work is complete.',
  ),
  Announcement(
    id: 'recycling-drive',
    title: 'Student recycling drive',
    category: 'Community',
    date: '9 November 2026',
    preview: 'Bring clean paper and plastic to the campus collection point.',
    detail:
        'The student environment club will collect clean paper and plastic '
        'at the courtyard from noon to 3 pm on 9 November. Sort materials before '
        'arrival. Batteries and electronic waste cannot be accepted at this event.',
  ),
  Announcement(
    id: 'project-showcase',
    title: 'Student project showcase',
    category: 'Academic',
    date: '10 November 2026',
    preview: 'Discover prototypes and meet student project teams.',
    detail:
        'Visit Innovation Lab 1 from 1 to 4 pm on 10 November to see student '
        'project demonstrations. Teams will explain their designs and answer '
        'questions. Visitors can leave constructive feedback at each booth.',
  ),
];

const services = <CampusService>[
  CampusService(
    id: 'library',
    label: 'Library',
    icon: Icons.local_library,
    detailDestination: ServiceDestination(
      title: 'Library',
      description:
          'Borrow books, use quiet study spaces and ask for help finding academic resources.',
      location: 'Learning Centre, Level 1',
      hours: 'Monday to Friday, 8 am to 8 pm',
    ),
  ),
  CampusService(
    id: 'counselling',
    label: 'Counselling',
    icon: Icons.support_agent,
    detailDestination: ServiceDestination(
      title: 'Counselling',
      description:
          'Ask the reception team about confidential appointments for personal and study concerns.',
      location: 'Student Centre, Room 2',
      hours: 'Monday to Friday, 9 am to 5 pm',
    ),
  ),
  CampusService(
    id: 'accommodation',
    label: 'Accommodation',
    icon: Icons.apartment,
    detailDestination: ServiceDestination(
      title: 'Accommodation',
      description:
          'Get information about campus rooms, residence rules and maintenance requests.',
      location: 'Residence A, Ground Floor',
      hours: 'Monday to Friday, 9 am to 5 pm',
    ),
  ),
  CampusService(
    id: 'careers',
    label: 'Career Services',
    icon: Icons.work_outline,
    detailDestination: ServiceDestination(
      title: 'Career Services',
      description:
          'Discuss internship searches, review your CV and prepare for interviews with a career adviser.',
      location: 'Student Centre, Room 5',
      hours: 'Monday to Friday, 10 am to 4 pm',
    ),
  ),
  CampusService(
    id: 'sports',
    label: 'Sports',
    icon: Icons.sports_basketball,
    detailDestination: ServiceDestination(
      title: 'Sports',
      description:
          'Ask reception about court bookings, equipment loans and campus team activities.',
      location: 'Sports Hall reception',
      hours: 'Monday to Saturday, 8 am to 8 pm',
    ),
  ),
  CampusService(
    id: 'it',
    label: 'IT Helpdesk',
    icon: Icons.computer,
    detailDestination: ServiceDestination(
      title: 'IT Helpdesk',
      description:
          'Get assistance with campus accounts, Wi-Fi access and learning platform issues. Never share your password.',
      location: 'Technology Building, Room G03',
      hours: 'Monday to Friday, 8:30 am to 5:30 pm',
    ),
  ),
];
