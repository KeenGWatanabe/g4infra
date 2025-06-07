# Adding submodules steps
```
cd /path/to/your/main/repo
git submodule add <repository-url> G4app
git commit -m "Added G4app as submodule"
git submodule update --remote
# since you can only update your own branch commit there first
git add .
git commit -m "add submodule"
git push origin -u branch
```
-----------------CAUTION!---------------
# Removing submodules
git submodule deinit -f vpc
git rm -f vpc
Remove-Item -Recurse -Force vpc
git config -f .gitmodules --remove-section submodule.vpc
git config -f .git/config --remove-section submodule.vpc

git add .gitmodules
git commit -m "Removed tf-backend submodule"
---------------------------------------------
"
   51d37d4..2aa49be  rger -> rger
branch 'rger' set up to track 'origin/rger'.
"
the create a pull-request and check if merge is able.
![PR merge check](/images/PRcompare.png)



# Deepseek
# Creating Git Submodules in Your Repository

The warning message you're seeing indicates you tried to add a regular directory that contains a Git repository to your main repository. Git is suggesting you use submodules instead, which is the correct way to include other repositories within your main repository.

## How to Properly Add Submodules

To add a submodule (in this case for "G4app"), follow these steps:

1. **Navigate to your main repository**:
   ```bash
   cd /path/to/your/main/repo
   ```

2. **Add the submodule**:
   ```bash
   git submodule add <repository-url> G4app
   ```
   Replace `<repository-url>` with the actual URL of the G4app repository.

3. **Commit the changes**:
   ```bash
   git commit -m "Added G4app as submodule"
   ```

## Working with Submodules

- **Cloning a repository with submodules**:
  When someone clones your repository, they'll need to initialize and update the submodules:
  ```bash
  git clone <your-repo>
  cd <your-repo>
  git submodule init
  git submodule update
  ```
  Or in one command:
  ```bash
  git clone --recurse-submodules <your-repo>
  ```

- **Updating submodules**:
  To update all submodules to their latest commits:
  ```bash
  git submodule update --remote
  ```

## If You Already Added the Repository Incorrectly

If you've already added the files directly (triggering the warning), you should:

1. Remove the incorrectly added directory:
   ```bash
   git rm -r --cached G4app
   rm -rf G4app
   ```

2. Then add it properly as a submodule as shown above.

Submodules are great for including external projects while maintaining their separate version history and making it easy to update them independently.