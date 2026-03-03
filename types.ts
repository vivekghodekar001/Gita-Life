export type UserRole = 'student' | 'admin' | 'mentor';
export type StudentCategory = 'Favourite' | 'Regular' | 'Sankalpa' | 'Guest' | 'Volunteer' | 'Advanced seeker';
export type SessionStatus = 'Upcoming' | 'Ongoing' | 'Completed';
export type ResourceType = 'book' | 'photo' | 'video' | 'lecture' | 'audio';
export type MentorshipStatus = 'Pending' | 'Accepted' | 'Rejected';

export enum InitiationStatus {
  UNINITIATED = 'Uninitiated',
  ASPIRING = 'Aspiring',
  SHELTER = 'Shelter',
  FIRST_INITIATED = 'First Initiated',
  SECOND_INITIATED = 'Second Initiated'
}

export interface UserProfile {
  id: string;
  name: string;
  spiritualName?: string;
  email: string;
  phone: string;
  photoUrl?: string;
  status?: InitiationStatus | string;
  dob?: string;
  nativePlace?: string;
  currentAddress?: string;
  branch?: string;
  yearOfStudy?: string;
  role: UserRole;
  category: StudentCategory;
  hobbies?: string[];
  skills?: string[];
  introVideoUrl?: string;
  mentorId?: string;
  goals?: string;
  interests?: string[];
  dailyMalas?: number;
  createdAt: string;
}

export interface Session {
  id: string;
  title: string;
  description?: string;
  date: string;
  location: string;
  facilitator: string;
  type: 'Regular' | 'Camp' | 'Event' | 'Special';
  status: SessionStatus;
  attendeeIds: string[];
}

export interface Homework {
  id: string;
  sessionId: string;
  title: string;
  description: string;
  fileUrl?: string;
  dueDate: string;
}

export interface Submission {
  id: string;
  homeworkId: string;
  studentId: string;
  fileUrl?: string;
  status: 'Pending' | 'Submitted' | 'Graded';
  marks?: number;
  feedback?: string;
  submittedAt: string;
}

export interface Resource {
  id: string;
  title: string;
  type: ResourceType;
  category: string;
  url: string;
  thumbnailUrl?: string;
}

export interface Notification {
  id: string;
  title: string;
  message: string;
  timestamp: Date;
  isRead: boolean;
  type?: 'quote' | 'system';
}

export interface GitaQuote {
  verse: string;
  translation: string;
  purport: string;
  chapter: number;
  text: number;
}

export interface QuizQuestion {
  id: string;
  question: string;
  options: string[];
  correctAnswer: number;
  explanation?: string;
}

export interface Quiz {
  id: string;
  sessionId?: string;
  topic: string;
  questions: QuizQuestion[];
  createdBy?: string;
  createdAt: string;
}

export interface QuizResult {
  id: string;
  quizId: string;
  studentId: string;
  score: number;
  totalQuestions: number;
  completedAt: string;
}

export interface ChantingLog {
  id: string;
  userEmail: string;
  date: string;
  rounds: number;
}

export interface MentorshipRequest {
  id: string;
  studentId: string;
  mentorId: string;
  status: MentorshipStatus;
  message: string;
  createdAt: string;
}
