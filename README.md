# gentoo_update Mobile App

This repository is an Android mobile app that receives update reports  
from [gentoo_update](https://github.com/Lab-Brat/gentoo_update).  

This project 
[originates](https://wiki.gentoo.org/wiki/Google_Summer_of_Code/2023/Ideas/Automated_Gentoo_system_updater) 
from 2023 Google Summer of Code, more about it can be found in the 
[blog post](https://labbrat.net/blog/gsoc2023/gentoo_update_intro/) and 
[Gentoo Forums](https://forums.gentoo.org/viewtopic-p-8793827.html#8793827).  

#### Features
- UI
  - [x] Login Screen
  - [x] Reports Screen
  - [x] Profile Screen
  - [ ] Help Screen
- Backend
  - [x] Add security rules for Firestore
  - [x] Create a token on user sign-in
  - [x] Encrypt tokens
  - [ ] Encrypt update reports
  - [ ] Improve rate limiting
  - [ ] Create a cleaner to delete old inactive accounts and their data
- General
  - [x] Anonymous Login
  - [ ] Google/Github OAuth Login
  - [x] Create a mechanism to get tokens as input, verify them and route to correct users.

#### Usage
For details usage, please check [gentoo_update User Guide](https://blogs.gentoo.org/gsoc/2023/08/27/gentoo_update-user-guide/).

