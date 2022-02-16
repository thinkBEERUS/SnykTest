IF EXISTS
          (
          SELECT
                 *
          FROM
               sys.objects
          WHERE object_id = OBJECT_ID(N'[dbo].[ntfClientHealthCheckData]')
                AND type IN(
             N'P',
             N'PC'
                  ))
   DROP PROCEDURE
        [dbo].[ntfClientHealthCheckData]

EXEC sp_executesql
     @sql =
     N'CREATE PROCEDURE [dbo].[ntfClientHealthCheckData]
     @Email     INT      = 1,
     @FromDate  DATETIME = '''',
     @Triggered INT      = 0,
     @Scheduled INT      = 0,
     @Changes   INT      = 0,
     @Errors    INT      = 0,
     @SchemaID  INT      = 1
AS
   BEGIN
      DECLARE
             @MonitoredTemplates TABLE(
           NotificationID VARCHAR(200)
                                      );

      INSERT INTO @MonitoredTemplates(
             NotificationID
                           )
      SELECT
             sysNtf.NotificationID
      FROM
           cfgSystemNotifications sysNtf WITH(NOLOCK);
      IF(@FromDate = '''')
         SET @FromDate = DATEADD(week, -1, GETDATE())
      IF(@Email = 1)
         BEGIN
            DECLARE
                   @FromEmailAddress        VARCHAR(200) =
                    (
                    SELECT
                           FromEmailAddress
                    FROM
                         ntfGlobalSettings WITH(NOLOCK)
                    WHERE SchemaID = @SchemaID
                          AND (GETDATE() BETWEEN ValidFrom AND ValidTo)),
                   @ToEmailAddress          VARCHAR(200) =
                    (
                    SELECT
                           CONCAT(
                           (
                           SELECT
                                  [Value]
                           FROM
                                ntfSettings WITH(NOLOCK)
                           WHERE Code = ''SUPPORT_EMAIL''), '';'',
                           (
                           SELECT
                                  [Value]
                           FROM
                                ntfSettings WITH(NOLOCK)
                           WHERE Code = ''BE_CONSULTANT_EMAIL'')) [ToEmailAddress]),
                   @TotalSent               INT          =
                    (
                    SELECT
                           COUNT(1) [Sent]
                    FROM
                         ntfEmailsToBeSent snt WITH(NOLOCK)
                         JOIN ntfEmailsToBeSentLog lg WITH(NOLOCK)
                            ON snt.ObjectID = lg.FKObjectIDEmailsToBeSent
                               AND snt.SchemaID = lg.SchemaID
                    WHERE snt.DateTimeSent BETWEEN @FromDate AND GETDATE()
                          AND snt.EmailSent = 1
                          AND lg.Result = ''''
                          AND snt.TemplateName IN
                                                  (
                                                  SELECT
                                                         NotificationID
                                                  FROM
                                                       @MonitoredTemplates)),
                   @TotalFailed             INT          =
                    (
                    SELECT
                           COUNT(1) [Failed]
                    FROM
                         ntfEmailsToBeSent snt WITH(NOLOCK)
                         JOIN ntfEmailsToBeSentLog lg WITH(NOLOCK)
                            ON snt.ObjectID = lg.FKObjectIDEmailsToBeSent
                               AND snt.SchemaID = lg.SchemaID
                    WHERE snt.DateTimeSent BETWEEN @FromDate AND GETDATE()
                          AND lg.Result <> ''''
                          AND snt.TemplateName IN
                                                  (
                                                  SELECT
                                                         NotificationID
                                                  FROM
                                                       @MonitoredTemplates)),
                   @SystemTriggeredEnabled  INT          =
                    (
                    SELECT
                           COUNT(tmp.[Enabled])
                    FROM
                         ntfTemplate tmp WITH(NOLOCK)
                         LEFT JOIN ntfScheduledTasks tsk WITH(NOLOCK)
                            ON tmp.ObjectID = tsk.FKObjectIDTemplate
                               AND tmp.SchemaID = tsk.SchemaID
                    WHERE(GETDATE() BETWEEN tmp.ValidFrom AND tmp.ValidTo)
                         AND tsk.FKObjectIDTemplate IS NULL
                         AND tmp.[Enabled] = 1
                         AND tmp.NotificationTaskType IN
                                                         (
                                                         SELECT
                                                                NotificationID
                                                         FROM
                                                              @MonitoredTemplates)),
                   @SystemTriggeredDisabled INT          =
                    (
                    SELECT
                           COUNT(tmp.[Enabled])
                    FROM
                         ntfTemplate tmp WITH(NOLOCK)
                         LEFT JOIN ntfScheduledTasks tsk WITH(NOLOCK)
                            ON tmp.ObjectID = tsk.FKObjectIDTemplate
                               AND tmp.SchemaID = tsk.SchemaID
                    WHERE(GETDATE() BETWEEN tmp.ValidFrom AND tmp.ValidTo)
                         AND tsk.FKObjectIDTemplate IS NULL
                         AND tmp.[Enabled] = 0
                         AND tmp.NotificationTaskType IN
                                                         (
                                                         SELECT
                                                                NotificationID
                                                         FROM
                                                              @MonitoredTemplates))

            SELECT
                   @FromEmailAddress        [FromEmailAddress]
                 , @ToEmailAddress          [ToEmailAddress]
                 , @TotalSent               [TotalSent]
                 , @TotalFailed             [TotalFailed]
                 , @SystemTriggeredEnabled  [SystemTriggeredEnabled]
                 , @SystemTriggeredDisabled [SystemTriggeredDisabled]
      END
       ELSE
         BEGIN
            IF(@Triggered = 1)
               BEGIN
                  SELECT
                         tmp.NotificationTaskType [Template Name]
                       , tmp.[Description]        [Description]
                       , COUNT(1)                 [EmailsSent]
                       , CAST(GETDATE() AS DATE)    [LastSent]
                  FROM
                       ntfEmailsToBeSent snt WITH(NOLOCK)
                       JOIN ntfTemplate tmp WITH(NOLOCK)
                          ON snt.TemplateName = tmp.NotificationTaskType
                             AND snt.SchemaID = tmp.SchemaID
                       LEFT JOIN ntfScheduledTasks tsk WITH(NOLOCK)
                          ON tmp.ObjectID = tsk.FKObjectIDTemplate
                             AND tmp.SchemaID = tsk.SchemaID
                             AND (GETDATE() BETWEEN tsk.ValidFrom AND tsk.ValidTo)
                  WHERE(GETDATE() BETWEEN tmp.ValidFrom AND tmp.ValidTo)
                       AND tsk.FKObjectIDTemplate IS NULL
                       AND snt.EmailSent = 1
                       AND (snt.DateTimeSent BETWEEN @FromDate AND GETDATE())
                       AND snt.TemplateName IN
                                               (
                                               SELECT
                                                      NotificationID
                                               FROM
                                                    @MonitoredTemplates)
                  GROUP BY
                           tmp.NotificationTaskType
                         , tmp.[Description]
            END
            IF(@Scheduled = 1)
               BEGIN
                  SELECT
                         tmp.NotificationTaskType [Template Name]
                       , tmp.[Description]        [Description]
                       , ISNULL(NULLIF(ISNULL(NULLIF(CAST(tmp.[Enabled] AS VARCHAR), ''1''), ''Yes''),
                       ''0''), ''No'')                [TemplateActive]
                       , COUNT(1)                 [EmailsSent]
                       , MAX(CAST(snt.DateTimeSent AS DATE))    [LastSent]
                  FROM
                       ntfEmailsToBeSent snt WITH(NOLOCK)
                       JOIN ntfTemplate tmp WITH(NOLOCK)
                          ON snt.TemplateName = tmp.NotificationTaskType
                             AND snt.SchemaID = tmp.SchemaID
                       JOIN ntfScheduledTasks tsk WITH(NOLOCK)
                          ON tmp.ObjectID = tsk.FKObjectIDTemplate
                             AND tmp.SchemaID = tsk.SchemaID
                  WHERE(GETDATE() BETWEEN tmp.ValidFrom AND tmp.ValidTo)
                       AND (GETDATE() BETWEEN tsk.ValidFrom AND tsk.ValidTo)
                       AND tsk.FKObjectIDTemplate IS NOT NULL
                       AND snt.EmailSent = 1
                       AND (snt.DateTimeSent BETWEEN @FromDate AND GETDATE())
                       AND snt.TemplateName IN
                                               (
                                               SELECT
                                                      NotificationID
                                               FROM
                                                    @MonitoredTemplates)
                  GROUP BY
                           tmp.NotificationTaskType
                         , tmp.[Description]
                         , tmp.[Enabled]
            END
            IF(@Changes = 1)
               BEGIN

                  /*Triggered*/

                  SELECT
                         tmp.NotificationTaskType        [Template Name]
                       , tmp.[Description]               [Description]
                       , ISNULL(NULLIF(ISNULL(NULLIF(CAST(tmp.[Enabled] AS VARCHAR), ''1''),
                       ''Enabled''), ''0''), ''Disabled'')     [TemplateActive]
                       , CONCAT(snt.ToEmailAddress, '';'',
                                                    CASE snt.CCEmailAddress
                                                     WHEN ''''
                                                     THEN ''''
                                                     ELSE CONCAT(snt.CCEmailAddress, '';'')
                                                    END,
                                                    CASE snt.BCCEmailAddress
                                                     WHEN ''''
                                                     THEN ''''
                                                     ELSE CONCAT(snt.BCCEmailAddress, '';'')
                                                    END) [Recipients]
                  FROM
                       ntfEmailsToBeSent snt WITH(NOLOCK)
                       JOIN ntfTemplate tmp WITH(NOLOCK)
                          ON snt.TemplateName = tmp.NotificationTaskType
                             AND snt.SchemaID = tmp.SchemaID
                       JOIN ntfTemplateItems tmpItems WITH(NOLOCK)
                          ON tmp.ObjectID = tmpItems.FKObjectIDTemplate
                             AND tmp.SchemaID = tmpItems.SchemaID
                             AND (GETDATE() BETWEEN tmpItems.ValidFrom AND tmpItems.ValidTo)
                       LEFT JOIN ntfScheduledTasks tsk WITH(NOLOCK)
                          ON tmp.ObjectID = tsk.FKObjectIDTemplate
                             AND tmp.SchemaID = tsk.SchemaID
                             AND (GETDATE() BETWEEN tsk.ValidFrom AND tsk.ValidTo)
                  WHERE(GETDATE() BETWEEN tmp.ValidFrom AND tmp.ValidTo)
                       AND tsk.FKObjectIDTemplate IS NULL
                       AND ((tmp.EditedDate BETWEEN @FromDate AND GETDATE())
                            OR (tmpItems.EditedDate BETWEEN @FromDate AND GETDATE()))
                       AND snt.TemplateName IN
                                               (
                                               SELECT
                                                      NotificationID
                                               FROM
                                                    @MonitoredTemplates)

                  /*Scheduled*/

                  SELECT
                         tmp.NotificationTaskType [Template Name]
                       , tmp.[Description]
                       , tmp.EditedDate
                       , ISNULL(NULLIF(ISNULL(NULLIF(CAST(tmp.[Enabled] AS VARCHAR), ''1''),
                       ''Enabled''), ''0''), ''Disabled'')     [TemplateActive]
                       , ISNULL(NULLIF(ISNULL(NULLIF(CAST(tsk.[Enabled] AS VARCHAR), ''1''),
                       ''Enabled''), ''0''), ''Disabled'')     [ScheduleActive]
                       , CONCAT(tskSchedule.ScheduledTaskPeriodFrequencyCode, tskSchedule.
                       ScheduledTaskPeriodMonthCode, tskSchedule.ScheduledTaskPeriodTypeCode)
                                                         [Frequency]
                       , CONCAT(snt.ToEmailAddress, '';'',
                                                    CASE snt.CCEmailAddress
                                                     WHEN ''''
                                                     THEN ''''
                                                     ELSE CONCAT(snt.CCEmailAddress, '';'')
                                                    END,
                                                    CASE snt.BCCEmailAddress
                                                     WHEN ''''
                                                     THEN ''''
                                                     ELSE CONCAT(snt.BCCEmailAddress, '';'')
                                                    END) [Recipients]
                  FROM
                       ntfEmailsToBeSent snt WITH(NOLOCK)
                       JOIN ntfTemplate tmp WITH(NOLOCK)
                          ON snt.TemplateName = tmp.NotificationTaskType
                             AND snt.SchemaID = tmp.SchemaID
                       JOIN ntfTemplateItems tmpItems WITH(NOLOCK)
                          ON tmp.ObjectID = tmpItems.FKObjectIDTemplate
                             AND tmp.SchemaID = tmpItems.SchemaID
                             AND (GETDATE() BETWEEN tmpItems.ValidFrom AND tmpItems.ValidTo)
                       JOIN ntfScheduledTasks tsk WITH(NOLOCK)
                          ON tmp.ObjectID = tsk.FKObjectIDTemplate
                             AND snt.SchemaID = tsk.SchemaID
                             AND (GETDATE() BETWEEN tsk.ValidFrom AND tsk.ValidTo)
                       JOIN ntfScheduledTaskPeriods tskSchedule WITH(NOLOCK)
                          ON tsk.ObjectID = tskSchedule.FKObjectIDScheduledTasks
                             AND tsk.SchemaID = tskSchedule.SchemaID
                  WHERE(GETDATE() BETWEEN tmp.ValidFrom AND tmp.ValidTo)
                       AND ((tmp.EditedDate BETWEEN @FromDate AND GETDATE())
                            OR (tmpItems.EditedDate BETWEEN @FromDate AND GETDATE()))
                       AND snt.TemplateName IN
                                               (
                                               SELECT
                                                      NotificationID
                                               FROM
                                                    @MonitoredTemplates)
            END
            IF(@Errors = 1)
               BEGIN
                  SELECT
                         tmp.NotificationTaskType [Template Name]
                       , tmp.[Description]
                       , CONCAT(snt.ToEmailAddress, '';'',
                                                    CASE snt.CCEmailAddress
                                                     WHEN ''''
                                                     THEN ''''
                                                     ELSE CONCAT(snt.CCEmailAddress, '';'')
                                                    END,
                                                    CASE snt.BCCEmailAddress
                                                     WHEN ''''
                                                     THEN ''''
                                                     ELSE CONCAT(snt.BCCEmailAddress, '';'')
                                                    END) [Recipients]
                       , errorLog.ErrorCode              [Error]
                  FROM
                       ntfEmailsToBeSent snt WITH(NOLOCK)
                       JOIN ntfTemplate tmp WITH(NOLOCK)
                          ON snt.TemplateName = tmp.NotificationTaskType
                             AND snt.SchemaID = tmp.SchemaID
                             AND (GETDATE() BETWEEN tmp.ValidFrom AND tmp.ValidTo)
                       JOIN ntfEmailsToBeSentLog lg WITH(NOLOCK)
                          ON snt.ObjectID = lg.FKObjectIDEmailsToBeSent
                             AND snt.SchemaID = lg.SchemaID
                       JOIN ntfErrorLog errorLog WITH(NOLOCK)
                          ON snt.ObjectID = errorLog.FKObjectIDEmailsToBeSent
                             AND snt.SchemaID = errorLog.SchemaID
                  WHERE(errorLog.CreatedDate BETWEEN @FromDate AND GETDATE())
                       AND lg.Result <> ''''
                       AND snt.TemplateName IN
                                               (
                                               SELECT
                                                      NotificationID
                                               FROM
                                                    @MonitoredTemplates)
            END
      END
   END'