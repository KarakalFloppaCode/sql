CREATE DATABASE Huspital;
GO
USE Huspital;
GO


CREATE TABLE Departments(
	Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Building] INT NOT NULL CHECK(Building >= 1 AND Building <=5),
	[Financing] MONEY NOT NULL CHECK (Financing >= 0) DEFAULT 0,
	[Name] NVARCHAR(100) NOT NULL UNIQUE,
);

CREATE TABLE Diseases(
	Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Name] NVARCHAR(100) NOT NULL UNIQUE,
);

CREATE TABLE Doctors(
	Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Name] NVARCHAR(max) NOT NULL,
	[Phone] CHAR(10),
	[Salary] MONEY CHECK (Salary > 0),
	[Surname] NVARCHAR(max) NOT NULL,
);

CREATE TABLE Examinations(
	Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Name] NVARCHAR(100) NOT NULL UNIQUE,
);

CREATE TABLE Wards(
	Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Name] NVARCHAR(100) NOT NULL UNIQUE,
	[Places] INT NOT NULL CHECK ( Places >= 1),
	[DepartmentId] INT NOT NULL,
	FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

CREATE TABLE DoctorsExaminations(
	Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Date] DATE NOT NULL CHECK ([Date] < GETDATE()),
	[DiseaseId] INT NOT NULL,
	FOREIGN KEY (DiseaseId) REFERENCES Diseases(Id), 
	[DoctorId] INT NOT NULL,
	FOREIGN KEY (DoctorId) REFERENCES Doctors(Id),
	[ExaminationId] INT NOT NULL,
	FOREIGN KEY (ExaminationId) REFERENCES Examinations(Id),
	[WardId] INT NOT NULL,
	FOREIGN KEY (WardId) REFERENCES Wards(Id)
);

CREATE TABLE Inters(
	Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[DoctorId] INT NOT NULL,
	FOREIGN KEY (DoctorId) REFERENCES Doctors(Id)
);

CREATE TABLE Professors(
	Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[DoctorId] INT NOT NULL,
	FOREIGN KEY (DoctorId) REFERENCES Doctors(Id)
);


SELECT * FROM Departments;
SELECT * FROM Diseases;
SELECT * FROM Doctors;
SELECT * FROM Examinations;
SELECT * FROM Wards;
SELECT * FROM DoctorsExaminations;
SELECT * FROM Inters;
SELECT * FROM Professors;

SELECT GETDATE();

DROP TABLE Professors;
DROP TABLE Inters;
DROP TABLE DoctorsExaminations;
DROP TABLE Wards;
DROP TABLE Examinations;
DROP TABLE Doctors;
DROP TABLE Diseases;
DROP TABLE Departments;

INSERT INTO Departments(Building, Financing, [Name])
VALUES
(1, 25000, 'Быковник'),
(2, 2000, 'Туполенд'),
(3, 3000, 'Скотомогильник'),
(4, 4000, 'Анкобольные'),
(5, 5000, 'Приветууту'),
(1, 8000, 'Ophthalmology'),
(2, 9000, 'Physiotherapy');

INSERT INTO Diseases([Name])
VALUES
('Туберкулёз'),
('Эбола'),
('Чума'),
('Ковид'),
('B-573'),
('Ветрянка');

INSERT INTO Doctors([Name], Phone, Salary, Surname)
VALUES
('Сергей', '1234567890', 25000, 'Петров'),
('Максим', '1234458735', 45000, 'Максимкович'),
('Денис', '1221421410', 10000, 'Денисов'),
('Борис', '1111111111', 15000, 'Борисов'),
('Артём', '1234435809', 5000, 'Артёмович'),
('Анна', '0987654321', 30000, 'Сидорова');


INSERT INTO Examinations([Name])
VALUES
('Проверка на вич'),
('Проверка чумы'),
('Тест на Ковид'),
('Тест на B-573'),
('Проверить Ветрянку');

INSERT INTO Wards([Name], Places, DepartmentId)
VALUES
('Ординаторская', 4, 1),
('Глазная', 3, 6),
('Физиопроцедурная', 2, 7),
('Хирургическая', 20, 5),
('Перединат', 10, 2),
('Девизионная', 15, 3),
('Втородинаторская', 5, 4);

INSERT INTO DoctorsExaminations([Date], DiseaseId, DoctorId, ExaminationId, WardId)
VALUES
('2026-11-6', 1, 1, 1, 1),
('2026-11-11', 2, 2, 2, 2),
('2026-10-1', 3, 3, 3, 4),
('2026-11-16', 1, 2, 1, 2),
('2026-11-16', 1, 2, 2, 3),
('2026-11-2', 4, 4, 4, 3),
('2026-11-17', 5, 5, 5, 1);

INSERT INTO Inters(DoctorId)
VALUES
(1),
(2),
(3),
(4),
(5);

INSERT INTO Professors(DoctorId)
VALUES
(1),
(2),
(3),
(4),
(5);


--1
SELECT W.[Name], W.Places
FROM Wards W
JOIN Departments D ON D.Id = W.DepartmentId
WHERE D.Building = 5
  AND W.Places >= 5
  AND EXISTS (
      SELECT 1
      FROM Wards W2
      JOIN Departments D2 ON D2.Id = W2.DepartmentId
      WHERE D2.Building = 5 AND W2.Places > 15);

--2
SELECT DISTINCT D.[Name]
FROM Departments D
JOIN Wards W ON W.DepartmentId = D.Id
JOIN DoctorsExaminations DE ON DE.WardId = W.Id
WHERE DE.[Date] >= DATEADD(DAY, -7, CONVERT(DATE, GETDATE()));


--3
SELECT Di.[Name]
FROM Diseases Di
WHERE NOT EXISTS (
    SELECT 1 FROM DoctorsExaminations DE WHERE DE.DiseaseId = Di.Id);

--4
SELECT Do.[Name], Do.Surname
FROM Doctors Do
WHERE NOT EXISTS (
    SELECT 1 FROM DoctorsExaminations DE WHERE DE.DoctorId = Do.Id);

--5
SELECT D.[Name]
FROM Departments D
WHERE NOT EXISTS (
    SELECT 1
    FROM Wards W
    JOIN DoctorsExaminations DE ON DE.WardId = W.Id
    WHERE W.DepartmentId = D.Id);


--6
SELECT DISTINCT Do.Surname
FROM Doctors Do
JOIN Inters I ON I.DoctorId = Do.Id;

--7
SELECT DISTINCT Do.Surname
FROM Doctors Do
JOIN Inters I ON I.DoctorId = Do.Id
WHERE Do.Salary > ANY (
    SELECT D2.Salary FROM Doctors D2 WHERE D2.Id <> Do.Id);

--8
SELECT W.[Name]
FROM Wards W
WHERE W.Places > ALL (
    SELECT W2.Places
    FROM Wards W2
    JOIN Departments D ON D.Id = W2.DepartmentId
    WHERE D.Building = 3);

--9
SELECT DISTINCT Do.Surname
FROM Doctors Do
JOIN DoctorsExaminations DE ON DE.DoctorId = Do.Id
JOIN Wards W ON W.Id = DE.WardId
JOIN Departments D ON D.Id = W.DepartmentId
WHERE D.[Name] = 'Ophthalmology'
  AND EXISTS (
      SELECT 1
      FROM DoctorsExaminations DE2
      JOIN Wards W2 ON W2.Id = DE2.WardId
      JOIN Departments D2 ON D2.Id = W2.DepartmentId
      WHERE DE2.DoctorId = Do.Id AND D2.[Name] = 'Physiotherapy');

--10
SELECT D.[Name]
FROM Departments D
WHERE EXISTS (
    SELECT 1
    FROM Wards W
    JOIN DoctorsExaminations DE ON DE.WardId = W.Id
    JOIN Inters I ON I.DoctorId = DE.DoctorId
    WHERE W.DepartmentId = D.Id
  )
  AND EXISTS (
    SELECT 1
    FROM Wards W
    JOIN DoctorsExaminations DE ON DE.WardId = W.Id
    JOIN Professors P ON P.DoctorId = DE.DoctorId
    WHERE W.DepartmentId = D.Id
  );

--11
SELECT Do.[Name], Do.Surname, D.[Name] AS Department
FROM Doctors Do
JOIN DoctorsExaminations DE ON DE.DoctorId = Do.Id
JOIN Wards W ON W.Id = DE.WardId
JOIN Departments D ON D.Id = W.DepartmentId
WHERE D.Financing > 20000;

--12
SELECT D.[Name]
FROM Departments D
JOIN Wards W ON W.DepartmentId = D.Id
JOIN DoctorsExaminations DE ON DE.WardId = W.Id
WHERE DE.DoctorId = (
    SELECT TOP 1 Id
    FROM Doctors
    ORDER BY Salary DESC);

--13
SELECT Di.[Name], COUNT(DE.Id) AS ExamsCount
FROM Diseases Di
LEFT JOIN DoctorsExaminations DE ON DE.DiseaseId = Di.Id
GROUP BY Di.[Name];


ALTER TABLE Doctors ALTER COLUMN [Name] NVARCHAR(100) NOT NULL;
ALTER TABLE Doctors ALTER COLUMN Surname NVARCHAR(100) NOT NULL;


SELECT t.name AS Таблица, i.name AS Индекс, i.type_desc AS Тип
FROM sys.indexes i
JOIN sys.tables t ON t.object_id = i.object_id
WHERE i.type_desc <> 'HEAP'
ORDER BY t.name;


-- поиск по корпусу
CREATE NONCLUSTERED INDEX IX_Departments_Building
ON Departments ([Building]);

-- Палаты по отделению
CREATE NONCLUSTERED INDEX IX_Wards_DepartmentId
ON Wards (DepartmentId);

-- все внешние ключи
CREATE NONCLUSTERED INDEX IX_DE_DoctorId
ON DoctorsExaminations (DoctorId);

CREATE NONCLUSTERED INDEX IX_DE_DiseaseId
ON DoctorsExaminations (DiseaseId);

CREATE NONCLUSTERED INDEX IX_DE_ExaminationId
ON DoctorsExaminations (ExaminationId);

CREATE NONCLUSTERED INDEX IX_DE_WardId
ON DoctorsExaminations (WardId);

-- интерны и професора
CREATE NONCLUSTERED INDEX IX_Inters_DoctorId
ON Inters (DoctorId);

CREATE NONCLUSTERED INDEX IX_Professors_DoctorId
ON Professors (DoctorId);

-- поиск врача по фамилии
CREATE NONCLUSTERED INDEX IX_Doctors_Surname
ON Doctors (Surname);


DROP INDEX IX_DE_DoctorId ON DoctorsExaminations;



-- Осмотры врача за период
CREATE NONCLUSTERED INDEX IX_DE_DoctorId_Date
ON DoctorsExaminations (DoctorId, [Date]);

-- Что обследовали в палате
CREATE NONCLUSTERED INDEX IX_DE_WardId_DiseaseId
ON DoctorsExaminations (WardId, DiseaseId);



SELECT de.[Date], d.Surname, e.[Name], dis.[Name], w.[Name]
FROM DoctorsExaminations de
JOIN Doctors d ON d.Id = de.DoctorId
JOIN Examinations e ON e.Id = de.ExaminationId
JOIN Diseases dis ON dis.Id = de.DiseaseId
JOIN Wards w ON w.Id = de.WardId
WHERE de.DoctorId = 2;



CREATE NONCLUSTERED INDEX IX_DE_DoctorId_Date_Cover
ON DoctorsExaminations (DoctorId, [Date])
INCLUDE (ExaminationId, DiseaseId, WardId);
DROP INDEX IX_DE_DoctorId_Date ON DoctorsExaminations;


--список палат отделения с вместимостью и финансированием отделения
CREATE NONCLUSTERED INDEX IX_Wards_DepartmentId_Cover
ON Wards (DepartmentId) INCLUDE ([Name], Places);

--отделения корпуса: номер корпуса, название и финансирование
CREATE NONCLUSTERED INDEX IX_Departments_Building_Cover
ON Departments ([Building]) INCLUDE ([Name], Financing);


--Врачи у которых указан телефон
CREATE NONCLUSTERED INDEX IX_Doctors_Phone
ON Doctors (Phone)
WHERE Phone IS NOT NULL;

--врачи с высокой зарплатой
CREATE NONCLUSTERED INDEX IX_Doctors_Salary
ON Doctors (Salary)
WHERE Salary >= 20000;

-- большие палаты 
CREATE NONCLUSTERED INDEX IX_Wards_Places
ON Wards (DepartmentId, Places)
WHERE Places >= 10;




--1 поиск врача по фамилии:
SELECT * FROM Doctors WHERE Surname = 'Максимкович';

--2 осмотры врача за период:
SELECT [Date], ExaminationId, WardId
FROM DoctorsExaminations
WHERE DoctorId = 2 AND [Date] BETWEEN '2026-10-01' AND '2026-11-30';

--3 врачи с зарплатой от 20 000:
SELECT Surname, Salary FROM Doctors WHERE Salary >= 20000;

--4 палаты отделения 2
SELECT w.[Name], w.Places
FROM Wards w
WHERE w.DepartmentId = 2;
