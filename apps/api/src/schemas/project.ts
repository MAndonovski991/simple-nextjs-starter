import { z } from "zod";

export const ProjectCreate = z.object({
  name: z.string().min(1),
  description: z.string().optional()
});

export const Project = ProjectCreate.extend({
  id: z.string(),
  createdAt: z.string()
});

export type TProjectCreate = z.infer<typeof ProjectCreate>;
export type TProject = z.infer<typeof Project>;
